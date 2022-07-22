const PMS = require('PMS7003');

const lora = {
  pins: {tx:D8, rx: D6},
  resetPin: D3,
};

let pmsData = null;
var pms = null;
let shtData = null;
let batteryVoltage = null;
let joined = false;

const SCL_SDA = { "scl": D10, "sda": D9 };
//const SCL_SDA = { "scl": D14, "sda": D13 };
const PM_ENABLE = D12;
const PM_DATA = D5;
const PM_INTERVAL = 180000;
const READ_TIME = 30000;
const RETRY_JOIN_DELAY = 20000;

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
        lora.emit('retry');
      }
      if (result.type === 'Network joined') {
        console.log('Successfully joined the network');
        joined = true;
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
      if (result.type === 'NUM' && result.value === '0-2') {
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

const Ranges = {
  DIGITAL_INPUT: [0, 255],
  DIGITAL_OUTPUT: [0, 255],
  ANALOG_INPUT: [-327.68, 327.67],
  ANALOG_OUTPUT: [-327.68, 327.67],
  LUMINOSITY: [0, 65535],
  PRESENCE: [0, 1],
  TEMPERATURE: [-3276.8, 3276.7],
  RELATIVE_HUMIDITY: [0, 100],
  ACCELEROMETER: [-32.768, 32.767],
  MAGNETOMETER: [-32.768, 32.767],
  BAROMETRIC_PRESSURE: [0, 6553.5],
  GYROMETER: [-327.68, 327.67],
  GPS_LATITUDE: [-90.0, 90.0],
  GPS_LONGITUDE: [-180.0, 180.0],
  GPS_ALTITUDE: [-3276.8, 3276.7],
};

const Scales = {
  DIGITAL_INPUT: 1,
  DIGITAL_OUTPUT: 1,
  ANALOG_INPUT: 100,
  ANALOG_OUTPUT: 100,
  LUMINOSITY: 1,
  PRESENCE: 1,
  TEMPERATURE: 10,
  RELATIVE_HUMIDITY: 2,
  ACCELEROMETER: 1000,
  MAGNETOMETER: 1000,
  BAROMETRIC_PRESSURE: 10,
  GYROMETER: 100,
  GPS_LATITUDE: 10000,
  GPS_LONGITUDE: 10000,
  GPS_ALTITUDE: 100,
};

const Sizes = {
  DIGITAL_INPUT: 1,
  DIGITAL_OUTPUT: 1,
  ANALOG_INPUT: 2,
  ANALOG_OUTPUT: 2,
  LUMINOSITY: 2,
  PRESENCE: 1,
  TEMPERATURE: 2,
  RELATIVE_HUMIDITY: 1,
  ACCELEROMETER: 6,
  MAGNETOMETER: 6,
  BAROMETRIC_PRESSURE: 2,
  GYROMETER: 6,
  GPS: 9,
  CHANNEL_TYPE: 2,
  UINT8: 1,
  UINT16: 2,
  INT16: 2,
  THREE_AXIS: 6,
};

const Types = {
  DIGITAL_INPUT: 0,
  DIGITAL_OUTPUT: 1,
  ANALOG_INPUT: 2,
  ANALOG_OUTPUT: 3,
  LUMINOSITY: 101,
  PRESENCE: 102,
  TEMPERATURE: 103,
  RELATIVE_HUMIDITY: 104,
  ACCELEROMETER: 113,
  MAGNETOMETER: 114,
  BAROMETRIC_PRESSURE: 115,
  GYROMETER: 134,
  GPS: 136,
};

const rangeCheck = (min, max, value) => {
  if (value < min || value > max) {
    throw new RangeError(`The argument must be between ${min} and ${max}.`);
  }
};

const encodeChannelType = (channel, type) => {
  const buffer = new ArrayBuffer(Sizes.CHANNEL_TYPE);
  const dataView = new DataView(buffer);
  let offset = 0;
  [channel, type].forEach((value) => {
    dataView.setInt8(offset, value);
    offset += 1;
  });
  return buffer;
};

const encodeInt16 = function encodeInt16(value, scale) {
  if (scale == null) {
    scale = 1;
  }
  const buffer = new ArrayBuffer(Sizes.INT16);
  const dataView = new DataView(buffer);
  dataView.setInt16(0, (value * scale) | 0);
  return buffer;
};


const encodeUInt8 = function encodeUInt8(value, scale) {
  if (scale == null) {
    scale = 1;
  }
  const buffer = new ArrayBuffer(Sizes.UINT8);
  const dataView = new DataView(buffer);
  dataView.setUint8(0, (value * scale) | 0);
  return buffer;
};

var concatBuffer = (buffer1, buffer2) => {
  var tmp = new Uint8Array(buffer1.byteLength + buffer2.byteLength);
  tmp.set(new Uint8Array(buffer1), 0);
  tmp.set(new Uint8Array(buffer2), buffer1.byteLength);
  return tmp.buffer;
};

const encodeAnalogInput = (channel, value) => {
  const min = Ranges.ANALOG_INPUT[0];
  const max = Ranges.ANALOG_INPUT[1];
  rangeCheck(min, max, value);
  const chanb = encodeChannelType(channel, Types.ANALOG_INPUT);
  const snsb = encodeInt16(value, Scales.ANALOG_INPUT);
  return concatBuffer(chanb, snsb);
};

const encodeTemperature = (channel, degc) => {
  const min = Ranges.TEMPERATURE[0];
  const max = Ranges.TEMPERATURE[1];
  rangeCheck(min, max, degc);
  const chanb = encodeChannelType(channel, Types.TEMPERATURE);
  const snsb = encodeInt16(degc, Scales.TEMPERATURE);
    return concatBuffer(chanb, snsb);
};

const encodeHumidity = (channel, percent) => {
  const min = Ranges.RELATIVE_HUMIDITY[0];
  const max = Ranges.RELATIVE_HUMIDITY[1];
  rangeCheck(min, max, percent);
  const chanb = encodeChannelType(channel, Types.RELATIVE_HUMIDITY);
  const snsb = encodeUInt8(percent, Scales.RELATIVE_HUMIDITY);
    return concatBuffer(chanb, snsb);
};

lora.on('ready', () => {
  console.log('Finished setup, waiting for data..');
  lora.on('data', (pmsData, shtData, batteryVoltage) => {
    console.log('Disconnecting PM..');
    Serial1.unsetup();
    loraSetup();
    if (pmsData) {
      const pm10 = encodeAnalogInput(1, pmsData.dAtm.pm10);
      const pm2_5 = encodeAnalogInput(2, pmsData.dAtm.pm2_5);
      const temp = encodeTemperature(3, shtData.temp);
      const battery = encodeAnalogInput(4, batteryVoltage);
      const humidity = encodeHumidity(5, Math.round(shtData.humidity));
      const toSend = arrayBufferToHex(pm10) +
                     arrayBufferToHex(pm2_5) +
                     arrayBufferToHex(temp) +
                     arrayBufferToHex(battery) +
                     arrayBufferToHex(humidity);
      pmsData = null;
      Serial1.println(`AT+MSGHEX="${toSend}"`);
      console.log(`Sending ${toSend}`);
    } else {
      console.log('No PM data available.');
    }
  });
});

lora.on('done', () => {
  console.log('Sent message.');
});

lora.on('retry', () => {
  console.log(`Waiting ${RETRY_JOIN_DELAY/1000} seconds before trying to join network again..`);
  setTimeout(() => {
    console.log('Attempting to join..');
    Serial1.println('AT+JOIN');
  }, RETRY_JOIN_DELAY);
});

I2C1.setup(SCL_SDA);
var sht = require('SHT4x').connect(I2C1);
digitalWrite(PM_ENABLE, 0);
Bluetooth.setConsole(true);

setTimeout(() => {
  loraSetup(true);
}, 1000); // Give LoRa-E5 time to start up

const pmInterval = setInterval(() => {
  if (joined) {
    console.log('Turning on PM..');
    Serial1.unsetup();
    Serial1.removeAllListeners('data');
    pms = PMS.connect(Serial1, PM_DATA, PM_ENABLE, onPms);
    pms.wakeup();
    const readTime = setTimeout(() => {
      console.log('Turning off PM..');
      pms.sleep();
      setTimeout(() => {
         // wait for PM sensor to sleep before sending data
         lora.emit('data', pmsData, shtData, batteryVoltage);
      }, 1000);
    }, READ_TIME);
  }
}, PM_INTERVAL);
