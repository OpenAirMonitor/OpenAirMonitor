const lora = {
  pins: {tx:D8, rx: D6},
  resetPin: D3,
};

let joined = false;
const RETRY_JOIN_DELAY = 20000;

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

lora.on('ready', () => {
  console.log('Finished setup');
  setInterval(() => {
        Serial1.println(`AT+MSGHEX`);
        console.log(`Sending packet`);
  }, 30000);
});

lora.on('retry', () => {
  console.log(`Waiting ${RETRY_JOIN_DELAY/1000} seconds before trying to join network again..`);
  setTimeout(() => {
    console.log('Attempting to join..');
    Serial1.println('AT+JOIN');
  }, RETRY_JOIN_DELAY);
});

Serial1.setup(9600, lora.pins);
digitalWrite(lora.resetPin,1); // keep LoRa reset pin high

Bluetooth.setConsole(true);

setTimeout(() => {
  loraSetup(true);
}, 1000); // Give LoRa-E5 time to start up

