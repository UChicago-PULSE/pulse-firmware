#include <FlexCan_T4.h>

// Connect the CRX and CTX pins on the transceiver board to
// the CAN3 pins on the Teensy 4.1: CRX3: 30 and CTX3: 31.
// I'm pretty sure that in this case CRX -> CRX3 AND CTX -> CTX3. 

// May need a 120 ohm resistor somewhere
// Library from: https://github.com/tonton81/FlexCAN_T4

// Currently using CAN2.0, but we can also use the same library for CANFD

FlexCAN_T4<CAN3, RX_SIZE_256, TX_SIZE_16> CAN;

static CAN_message_t msg;
static uint8_t hex[17] = "0123456789abcdef"

void setup() {
    // initialize
    Serial.begin(9600);
    while(!Serial) ;

    Serial.println("This is a test of the CAN BUS send")

    CAN.begin();

    CAN.setBaudRate(1000000);

    // I have on idea what this does but it was in some forum post
    // there is also more info about filtering messages. Will need 
    // to look at that when communicating with both the ADCS and
    // the payload controller

    CAN.setMaxMB(16);
    CAN.enableFIFO();
    CAN.enableFIFOInterrupt();
    CAN.onReceive(canSniff);

    // shows the status of "mailboxes" whatever those are
    CAN.mailboxStatus();
}

// taken from github library page
void canSniff(const CAN_message_t &msg) {
    Serial.print("MB "); Serial.print(msg.mb);
    Serial.print(" OVERRUN: "); Serial.print(msg.flags.overrun);
    Serial.print(" LEN: "); Serial.print(msg.len);
    Serial.print(" EXT: "); Serial.print(msg.flags.extended);
    Serial.print(" TS: "); Serial.print(msg.timestamp);
    Serial.print(" ID: "); Serial.print(msg.id, HEX);
    Serial.print(" Buffer: ");
    for ( uint8_t i = 0; i < msg.len; i++ ) {
        Serial.print(msg.buf, HEX); Serial.print(" ");
    }
    Serial.println();
}

void loop() {
    // probably just like CAN.write(msg), but need to read docs more
}
