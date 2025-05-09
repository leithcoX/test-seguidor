/*
  * Disposición de los sensores en el modulo Sensor
  *  _________________________________________
  * |                                         |
  * |    S1    S2    S3    S4    S5    S6     |
  * |    _________                            |
  * |   |Integrado|                           |
  * |_________________________________________|
  *              | | | | | | | |
  *              1 2 3 4 5 6 V GND
  */

#define SENSORS_SIZE 6

typedef enum {
  SENSOR_1 = 2,
  SENSOR_2,
  SENSOR_3,
  SENSOR_4,
  SENSOR_5,
  SENSOR_6,
} SENSOR_PIN_T;


// Estructura representando el estado de los 6 Sensores
struct PinsState {
  bool states[6];

  PinsState(bool must_read) : states{0} {
    if (must_read) this->read();
  }

  // Actualiza el estado de los sensores leyendo de los pines
  void read() {
      for (int i = 0; i < SENSORS_SIZE; i++)
        this->states[i] = digitalRead(SENSOR_1 + i);
  }

  void print() {
    Serial.println("Sensor1\tSensor2\tSensor3\tSensor4\tSensor5\tSensor6");
    for (int i = 0; i < SENSORS_SIZE; i++) {
       Serial.print(states[i]);
       Serial.print("\t");
    }
    Serial.println("\n");
  }

  bool operator==(const PinsState& other) {
    for (int i = 0; i < SENSORS_SIZE; i++)
      if (this->states[i] != other.states[i])
        return false;
    return true;
  }

  bool operator!=(const PinsState& other) {
    return not ((*this) == other);
  }
  
  PinsState& operator=(const PinsState& other) {
	for (int i = 0; i < SENSORS_SIZE; i++)
      this->states[i] = other.states[i];
  }
};


void setup(){
  Serial.begin(9600);
  for (int i = 0; i < SENSORS_SIZE; i++)
       pinMode(SENSOR_1 + i, INPUT);
}

PinsState previous_state(false);

void loop() {
  PinsState current_state(true);
  if (not (current_state == previous_state)) {
    previous_state = current_state;
    previous_state.print();
  }
  delay(100); // Reducir el delay para más precisión
}

