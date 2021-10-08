const PMS = require('PMS7003');

const lora = {
  pins: {tx:D8, rx: D6},
  resetPin: D3,
};

let pmsData = null;
let shtData = null;
let batteryVoltage = null;

const SCL_SDA = { "scl": D10, "sda": D9 };
const PM_ENABLE = D12;
const PM_DATA = D5;
const PM_INTERVAL = 180000;
const READ_TIME = 30000;


const onPms = (d) => {
  // TODO: consider averaging the values

  if (d.checksumOk) {
        console.log('PM 2.5 data: ', d.dAtm.pm2_5);
        pmsData = d;
  } else {
      console.log('PMS checksum error!');
  }


  sht.read(function(d) {
    console.log('Temperature:', d.temp);
    console.log('Humidity:', d.humidity);
    shtData = d;
  });


  batteryVoltage = (analogRead(D31) * 3.3) * (100+30) / 100;
  console.log('Voltage read from pin:', batteryVoltage);
};

const arrayBufferToHex = (arrayBuffer) => {
  return (new Uint8Array(arrayBuffer)).slice().map(x=>(256+x).toString(16).substr(-2)).join("");
};

const loraSetup = (init = false) => {
  let buf = '';

  Serial1.setup(9600, lora.pins);
  digitalWrite(lora.resetPin,1); // keep LoRa reset pin high


  if (init) {
    lora.on('MSGHEX', (result) => {
      if (result.type === 'Done') {
        lora.emit('done');
      }
    });

    lora.on('JOIN', (result) => {
      if (result.type === 'Join failed') {
        console.log('Could not join the network');
      }

      if (result.type === 'Network joined') {
        console.log('Successfully joined the network');
        lora.emit('ready');
      }
    });

    lora.on('MODE', (result) => {
      if (result.type === 'LWOTAA') {
        console.log('Set mode to OTAA');
        Serial1.println('AT+JOIN');
      } else {
        console.log('Could not configure channels');
      }
    });

    lora.on('CH', (result) => {
      if (result.type === 'NUM' || result.value === '0-2') {
        console.log('Configured channels');
        Serial1.println('AT+MODE=LWOTAA');
      } else {
        console.log('Could not configure channels');
      }
    });

    lora.on('DR', (result) => {
      if (result.type === 'EU868') {
        console.log('Data rate set to 868MHz');
        Serial1.println('AT+CH=NUM,0-2');
      } else {
        console.log('Could not set data rate');
      }
    });

    Serial1.println('AT+DR=EU868');
  }

  // this should be after the other lora event listeners
  Serial1.on('data', (data) => {
    buf += data;
    var idx = buf.indexOf("\r");
    while ( idx >= 0) {
      const line = buf.substr(0, idx);
      buf = buf.substr(idx + 1);
      // print(line);
      const res = /\+(\w+):\s+([\w\s]+),*\s*(.*)/.exec(line);
      if (res) {
        const result = {
          cmd: res[1],
          type: res[2],
          value: res[3],
        };
        lora.emit(result.cmd, result);
      }
      idx = buf.indexOf("\r");
    }
  });
};

lora.on('ready', () => {
  console.log('Finished setup, waiting for data..');
  Serial1.unsetup();
  Serial1.removeAllListeners('data');
  pms = PMS.connect(Serial1, PM_DATA, onPms);

  lora.on('data', (pmsData, shtData, batteryVoltage) => {
    console.log('Disconnecting PM..');
    Serial1.unsetup();
    loraSetup();

    const buf = new ArrayBuffer(12);
    const view = new DataView(buf);

    if (pmsData) {
      view.setUint16(0, pmsData.dAtm.pm1);
      view.setUint16(2, pmsData.dAtm.pm2_5);
      view.setUint16(4, pmsData.dAtm.pm10);
      view.setUint16(6, batteryVoltage * 1000);
      view.setUint16(8, shtData.temp * 1000);
      view.setUint16(10, shtData.humidity * 1000);
      pmsData = null;

      const toSend = arrayBufferToHex(buf);

      Serial1.println(`AT+MSGHEX="${toSend}"`);
      console.log(`Sending ${toSend}`);
    } else {
      console.log('No PM data available.');
    }
  });
});

lora.on('done', () => {
  console.log('Sent message, reconnecting PMS..');
  Serial1.unsetup();
  Serial1.removeAllListeners('data');
  pms = PMS.connect(Serial1, PM_DATA, onPms);
});




I2C1.setup(SCL_SDA);
var sht = require('SHT4x').connect(I2C1);

digitalWrite(PM_ENABLE, 0);
loraSetup(true);

Bluetooth.setConsole(true);

const pmInterval = setInterval(() => {
  console.log('Turning on PM..');
  digitalWrite(PM_ENABLE, 1);
  Serial1.unsetup();
  Serial1.removeAllListeners('data');
  pms = PMS.connect(Serial1, PM_DATA, onPms);
  const readTime = setTimeout(() => {
    console.log('Turning off PM..');
    digitalWrite(PM_ENABLE, 0);
    lora.emit('data', pmsData, shtData, batteryVoltage);
  }, READ_TIME);
}, PM_INTERVAL);
