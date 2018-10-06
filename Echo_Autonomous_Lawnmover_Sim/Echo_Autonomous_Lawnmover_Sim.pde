final int FIELD_WIDTH = 1000;
final int FIELD_HEIGHT = 1000;

// Test Field in which all movement data will be referenced
int[][] field = new int[FIELD_HEIGHT][FIELD_WIDTH];

// Defines what each unit in the array ammounts to in meters
float unit = 0.5;


// Bot Dimensions specified  in meters
final float BOT_WIDTH = 16 / unit;
final float BOT_HEIGHT = 16 / unit;

// Bot position and rotation on the field, denoted by the center most point of the bot
float botXpos = 50;
float botYpos = 50;
float botAngle = 0;

// The four corners of the bot represented by an angle
float a1 = atan((BOT_HEIGHT / 2) / (BOT_WIDTH / 2));
float a2 = PI - atan((BOT_HEIGHT / 2) / (BOT_WIDTH / 2));
float a3 = PI + atan((BOT_HEIGHT / 2) / (BOT_WIDTH / 2));
float a4 = 2 * PI - atan((BOT_HEIGHT / 2) / (BOT_WIDTH / 2));

// Bot's rotational and linear speed (meters per second)
float botSpeed = 1 / unit;
float botRotSpeed = PI / 2;

int total_distance = 0;
float total_time = 0;

void setup() {
  size(1000, 1000);
  background(0);
  stroke(255);
  
  updateBotPos();
  for(int i = 0; i < 100; i++) {
    updateBotPos();
  }
  println(percentComplete());
  
}



void draw() {
  
  
  
}

// Calculate new position of bot
void updateBotPos() {
  total_time++;
  total_distance += unit;
  botXpos += unit * cos(botAngle); 
  botYpos += unit * sin(botAngle); 
  updateOutline();
  // If the bot is outside of field, make a turn to face the feild
  if((int)(botXpos) < 0 || (int)(botXpos) >= FIELD_WIDTH || (int)(botYpos) < 0 || (int)(botYpos) < FIELD_HEIGHT) {
    updateBotRot();
  }
}

// Calculate new angle of bot given an angle to increment to
void updateBotRot() {
  float goal = random(30,50);
  while(abs(goal - botAngle) > 0.0001) {
    // Increment by one degree
    botAngle += PI / 180;
    total_time += 1 / 90;
    updateOutline();
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
  if(!(n < 0) && !(n >= FIELD_WIDTH) && !(m < 0) && !(n >= FIELD_WIDTH)) {
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
