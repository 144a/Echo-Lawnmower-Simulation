PrintWriter output;

final int FIELD_WIDTH = 1000;
final int FIELD_HEIGHT = 1000;

// Test Field in which all movement data will be referenced
int[][] field = new int[FIELD_HEIGHT][FIELD_WIDTH];

int[][] island_data = new int[FIELD_HEIGHT][FIELD_WIDTH];

// Defines what each unit in the array ammounts to in meters
float unit = 0.5;


// Bot Dimensions specified  in meters
final float BOT_WIDTH = 16 / unit;
final float BOT_HEIGHT = 16 / unit;

// Bot position and rotation on the field, denoted by the center most point of the bot
float botXpos = 50;
float botYpos = 50;
float botAngle = PI / 3;

// The four corners of the bot represented by an angle
float a1 = atan((BOT_HEIGHT / 2) / (BOT_WIDTH / 2));
float a2 = PI - atan((BOT_HEIGHT / 2) / (BOT_WIDTH / 2));
float a3 = PI + atan((BOT_HEIGHT / 2) / (BOT_WIDTH / 2));
float a4 = 2 * PI - atan((BOT_HEIGHT / 2) / (BOT_WIDTH / 2));

// Bot's rotational and linear speed (meters per second)
float botSpeed = 1 / unit;
float botRotSpeed = PI / 2;

// Maximum possible "collision distance"
final float MAX_DIST = 1;

float total_distance = 0;
float total_time = 0;

int count = 0;

void setup() {
  size(1000, 1000);
  background(0);
  stroke(255);
  frameRate(300);
  
  // Set up text file for data logging
  output = createWriter("datalog.txt"); 
  
  // Set up basic island data (TEMPORARY)
  populateIslandArray();
}



void draw() {
  count++;
  updateBotPos();
  if(checkCollision()) {
    println("Collision");
    updateBotRot();
  }
  
  
  if(count > 10) {
    count = 0;
    
    float tempperc = percentComplete();
    // Write to both the console and text file
    println("Total Time= " + total_time);
    output.println("Total Time= " + total_time);
    println("Total Distance= " + total_distance);
    output.println("Total Distance= " + total_distance);
    println("Percent Mown= " + tempperc);
    output.println("Percent Mown= " + tempperc);
    if(tempperc >= 98) {
      // Writes the remaining data to the file
      output.flush(); 
      // Finishes the file
      output.close(); 
      exit();
    }
  }
}

// If a key is pressed, it will save the data and close the simulation
void keyPressed() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  exit(); // Stops the program
}

// Create Empty island data array
void populateIslandArray() {
  for(int i = 0; i < island_data.length; i++) {
    island_data[i][0] = 1;
    island_data[i][island_data[0].length - 1] = 1;
  }
  
  for(int i = 0; i < island_data[0].length; i++) {
    island_data[0][i] = 1;
    island_data[island_data.length - 1][i] = 1;
  }
}

// Calculate new position of bot
void updateBotPos() {
  total_time++;
  total_distance += unit;
  botXpos += unit * cos(botAngle); 
  botYpos += unit * sin(botAngle); 
  updateOutline();
  
  /*
  // If the bot is outside of field, make a turn to face the feild
  if((int)(botXpos) < 0 || (int)(botXpos) >= FIELD_WIDTH || (int)(botYpos) < 0 || (int)(botYpos) >= FIELD_HEIGHT) {
    updateBotRot();
  }
  */
  
}

// Check for collision between bot and borders
boolean checkCollision() {
  boolean ret = false;
  float minDist = 999999999;
  int tempx = 0;
  int tempy = 0;
  float temp = 999999999;
  for(int i = (int)(botXpos); i < BOT_HEIGHT * sqrt(2) + (int)(botXpos); i++) {
    for(int j = (int)(botYpos); j < BOT_WIDTH * sqrt(2) + (int)(botYpos); j++) {
      // Check to make sure point is in bounds, and then check to see if island_data[j][i] is equal to 1
      if(!(j < 0 || j >= FIELD_WIDTH || i < 0 || i >= FIELD_HEIGHT) && island_data[j][i] == 1) {
        temp = (int)(sqrt((i - botXpos) * (i - botXpos) + (j - botYpos) * (j - botYpos)));
        if(temp < minDist) {
          minDist = temp;
          tempx = i;
          tempy = j;
        }
      }
    }
  }
  
  // Check distance for maximum possible "collision distance"
  if(minDist <= MAX_DIST) {
    ret = true;
  }
  
  return ret;
}



// Calculate new angle of bot given an angle to increment to while taking into account time to get there
void updateBotRot() {
  updateBotPos();
  updateBotPos();
  updateBotPos();
  float tempAngle = botAngle;
  while(checkCollision()){
    botAngle -= PI;
    updateBotPos();
    updateBotPos();
    updateBotPos();
    botAngle += PI;
    botAngle = tempAngle;
    float goal = random(60,120);
    int testDir = (int)(random(0, 2));
    println("new angle: " + goal + botAngle);
    if(testDir == 0) {
      goal *= -1;
    }
    shiftBotAngle(goal);
    updateBotPos();
    updateBotPos();
    updateBotPos();
    println("Turning");
  }
  
  // Old Rotation Code
  /*
  float goal = random(50,85);
  float tempAngle = botAngle;
  println("new angle: " + goal + botAngle);
  while(abs((tempAngle + radians(goal)) - botAngle) > 0.1) {
    // Increment by one degree
    botAngle += PI / 180;
    total_time += 1 / 90;
    updateOutline();
  }
  */
}

// Shifts current bot angle to new angle
void shiftBotAngle(float degree) {
  float temp = botAngle;
  int dir = 1;
  if(degree < 0) {
    dir = -1;
  }
  while(abs((temp + radians(degree)) % (2 * PI) - botAngle % (2 * PI)) > 0.1) {
    // Increment by one degree
    botAngle += PI / 180 * dir;
    total_time += 1 / 90;
    updateOutline();
    println(botAngle);
  }
}



// Calculates current outline using position and angle, then adds data to field
void updateOutline() {
  // Calculate 4 corners using bot dimensions
  int centerx = (int)(botXpos);
  int centery = (int)(botYpos);
  stroke(0);
  point(centerx, centery);
  stroke(255);
  float a1X = centerx + cos(a1) * (BOT_WIDTH / 2);
  float a1Y = centery + sin(a1) * (BOT_HEIGHT / 2);
  float a2X = centerx + cos(a2) * (BOT_WIDTH / 2);
  float a2Y = centery + sin(a2) * (BOT_HEIGHT / 2);
  float a3X = centerx + cos(a3) * (BOT_WIDTH / 2);
  float a3Y = centery + sin(a3) * (BOT_HEIGHT / 2);
  float a4X = centerx + cos(a4) * (BOT_WIDTH / 2);
  float a4Y = centery + sin(a4) * (BOT_HEIGHT / 2);
  genLineOutline(a1X, a1Y, a2X, a2Y);
  genLineOutline(a2X, a2Y, a3X, a3Y);
  genLineOutline(a3X, a3Y, a4X, a4Y);
  genLineOutline(a4X, a4Y, a1X, a1Y);
  
}

// Calculates points of the line approximation between two points
void genLineOutline(float x0, float y0, float x1, float y1) {
  // Highest x value must be x1
  if(x1 < x0) {
    float tempx = x1;
    float tempy = y1;
    x1 = x0;
    y1 = y0;
    x0 = tempx;
    y0 = tempy;
  }
  
  float deltax = x1 - x0;
  float deltay = y1 - y0;
  
  // Checks for vertical lines and handles them seperately
  if(abs(deltax) > 0.00001) {
    
    float deltaerr = abs(deltay / deltax);
    float error = 0;
    int y = (int)(y0);
    for(int x = (int)(x0); x <= (int)(x1); x++) {
      updatePoint(x,y);
      point(x,y);
      error += deltaerr;
      if(error >= 0.5) {
        y += deltay / abs(deltay);
        error -= 1;
      }
    }
  } else {
    // Highest y value must be y1
  if(y1 < y0) {
    float tempx = x1;
    float tempy = y1;
    x1 = x0;
    y1 = y0;
    x0 = tempx;
    y0 = tempy;
  }
    for(int y = (int)(y0); y < (int)(y1); y++) {
      updatePoint((int)(x0),y);
      point((int)(x0),y);
    }
  }
}


void updatePoint(int n, int m) {
  if(!(n < 0) && !(n >= FIELD_WIDTH) && !(m < 0) && !(m >= FIELD_WIDTH)) {
    if(field[m][n] != 1) {
      field[m][n] = 1;
    }
  }
}



// Calculates percentage of Field Complete
float percentComplete() {
  int sum = 0;
  for(int i = 0; i < FIELD_HEIGHT; i++) {
    for(int j = 0; j < FIELD_WIDTH; j++) {
      if(field[i][j] == 1) {
        sum++;
      }
    }
  }
  
  return (sum / (float)(FIELD_WIDTH * FIELD_HEIGHT)) * 100;
  
}

// Line Generation algorithm
// Only used for demonstating function
void lineGen(float x0, float y0, float x1, float y1) {
  float deltax = x1 - x0;
  float deltay = y1 - y0;
  // This assumes deltax != 0 (line is not vertical)
  float deltaerr = abs(deltay / deltax);
  float error = 0;
  int y = (int)(y0);
  for(int x = (int)(x0); x <= (int)(x1); x++) {
    point(x,y);
    error += deltaerr;
    if(error >= 0.5) {
      y += deltay / abs(deltay);
      error -= 1;
    }
  }
}
