/* Tinydraw by Thomas Bruninx
 *
 */
 
// Build number
final int BUILD = 1001;
 
// Variables
int brushSize = 32, colorIndex = 0;
int[] colorRGB = {0, 0, 0};
PGraphics image, currentMessage;
boolean drawMode = false, eraseMode = false, pickMode = false, messageMode = false, drawHud = true, largeAmount = false;

// Subroutine containing everything to do at application start
void setup() {
  size(800, 600);       // Set window size to 800x600 pixels
  frameRate(60);        // Set desired framerate to 60 fps
  
  showHelp(true);       // Display startup message
  initImage();          // Initialize the image
}




// Main drawing loop
void draw() {
  background(255);      // Clear viewport
  image(image, 0, 0);   // Draw image to viewport
  
  // Check which mode the program is in
  if(messageMode) {
    // If in message mode, display the current message
    image(currentMessage ,(width - 600) / 2, (height - 400) / 2);
  } else {
    // If in pick mode, don't draw anything
    // If in draw/erase/view mode, draw a brush
    if (!pickMode) {
      noStroke();
      fill(colorRGB[0], colorRGB[1], colorRGB[2]);
      ellipse(mouseX, mouseY, brushSize, brushSize);
    }
  }
  
  // Draw hud when enabled
  if(drawHud) {
    fill(0);
    textSize(11);
    text("(" + mouseX + "," + mouseY + ") " + brushSize + 
         "px " + (colorIndex == 0 ? "[R]GB" : (colorIndex == 1 ? "R[G]B" : "RG[B]" )) + 
         "(" + colorRGB[0] + "," + colorRGB[1] + "," +
         colorRGB[2] + ")" + (largeAmount ? "+10" : "+1") , 2, 13);
  }
  
}





/*******************************************************************
* Event handlers                                                   *
*******************************************************************/

// Handle mouse wheel input
void mouseWheel(MouseEvent e) {
  int wheel = e.getCount();  // Get the amount the wheel was scrolled
  
  if ((brushSize > 8 || wheel > 0) && (brushSize < 512 || wheel < 0)) {
    brushSize += wheel;  // Adjust the brush size 
  }
}

// Handle mouse button pressed
void mousePressed(MouseEvent e) {
  int button = e.getButton();  // Get which button was pressed
  
  // Check if application is currently displaying a message
  if (messageMode) {
    // If in message mode, hide message
    resetMessage();
  } else if (pickMode) {
    // If in pick mode, get color beneath color
    color c = get(mouseX, mouseY);
    colorRGB[0] = (int)red(c);
    colorRGB[1] = (int)green(c);
    colorRGB[2] = (int)blue(c);
  } else {
    switch (button) {
      // Set draw mode
      case LEFT:
        drawMode = true;
        break;

      // Set erase mode
      case RIGHT:
        eraseMode = true;
        break;
    }  
    
    thread("updateImage");
  }
}

// Handle mouse button released
void mouseReleased(MouseEvent e) {
  int button = e.getButton();  // Get which button was pressed
  
  // Reset mode
  switch (button) {
    case LEFT:
      drawMode = false;
      break;
    case RIGHT:
      eraseMode = false;
      break;
  }  
}

// Handle keyboard input
void keyPressed(KeyEvent e) {
  int key = e.getKeyCode();
  
  // Check if application is currently displaying a message
  if (messageMode) {
    resetMessage();
  } else {
    // Check which key was pressed, special keys first
    switch (key) {
      case ESC:
        stop();  // End application ig Escape is pressed
        break;
      case UP:
        // Change color value (0 - 255) increase
        if (colorRGB[colorIndex] < 255) {
          if (largeAmount) {
            colorRGB[colorIndex]+=(colorRGB[colorIndex] + 10 <= 255 ? 10 : 1);
          } else {
            colorRGB[colorIndex]++;
          }
        } 
        break;
      case DOWN:
        // Change color value (0 - 255) decrease
        if (colorRGB[colorIndex] > 0) {
          if (largeAmount) {
            colorRGB[colorIndex]-=(colorRGB[colorIndex] - 10 >= 0 ? 10 : 1);
          } else {
            colorRGB[colorIndex]--;
          }
        } 
        break;
      case LEFT:
        // Change color index (R, G or B) next
        if (colorIndex > 0)
          colorIndex--;
        break;
      case RIGHT:
        // Change color index (R, G or B) previous
        if (colorIndex < 2)
          colorIndex++;
        
        break;
      case SHIFT: 
        // Enable to change color value per 10
        largeAmount = (largeAmount ? false : true);
        break;
      // If it wasn't a special key, check character keys
      default:
      key = e.getKey();
      switch (key) {
        case 'H':
        case 'h':
          // Display help message
          showHelp(false);
          break;
        case 'S':
        case 's':
          // Save current image
          saveToFile();
          break;
        case 'O':
        case 'o':
          // Load an existing image
          loadFromFile();
          break;
        case 'V':
        case 'v':
          // Switch HUD on or off
          drawHud = (drawHud ? false : true);
          break;
        case 'C':
        case 'c':
          // Clear image
          initImage();
          break;
        case 'M':
        case 'm':
          // Switch between pick or draw/erase/view mode
          pickMode = (pickMode ? false : true);
          break;
      }
    }  
  }
}

/*******************************************************************
* General Subroutines                                              *
*******************************************************************/

// Subroutine to show a message
void showMessage(String title, String[] content) {
  currentMessage = getMessage(title, content);
  messageMode = true;
}

// Subroutine to reset message mechanism
void resetMessage() {
  currentMessage = null;
  messageMode = false;
}

// Subroutine to create a message box
PGraphics getMessage(String title, String[] content) {
  PGraphics message = createGraphics(600, 400);
  
  // Start drawing on message
  message.beginDraw();
  
  // Draw a rectangle
  message.stroke(0);              // Enable stroke to add a border
  message.fill(255);              // Set color to white
  message.rect(0, 0, 599, 399);   // Draw
  
  // Write title
  message.textSize(24);           // Set text size to 24px
  message.fill(0);                // Set color to black
  message.text(title, 6, 28);     // Draw
  
  // Write content line by line
  message.textSize(18);           // Set text size to 18px
  message.fill(78);               // Set text color to grey
  for (int i = 0; i < (content.length <= 18 ? content.length : 18); i++) {
    message.text(content[i], 6, 54 + (20 * i));  // Draw
  }
  
  // End drawing on message
  message.endDraw();
  
  // Return message
  return message;
}

// Subroutine to init a new image
void initImage() {
  image = createGraphics(width, height);
  
  image.beginDraw();
  image.background(255);
  image.noStroke();
  image.endDraw();
}

// Subroutine to update image
void updateImage() {
  while (drawMode || eraseMode) {
    image.beginDraw();
    if (eraseMode) {
      image.fill(255);
    } else {
      image.fill(colorRGB[0], colorRGB[1], colorRGB[2]);
    }
    image.ellipse(mouseX, mouseY, brushSize, brushSize);
    image.endDraw();
  }
}

// Subroutine to load an image
void loadFromFile() {
  PImage img = loadImage("drawing.png");  // Load the image file
  
  initImage();             // Clear current image 
  image.beginDraw();       // Start drawing
  image.image(img, 0, 0);  // Draw loaded image on new image
  image.endDraw();         // End drawing
  
  // Show message to tell the image was loaded
  String title = "Image loaded";
  String[] content = {"drawing.png has been loaded."};
  showMessage(title, content);
}

// Subroutine to save an image
void saveToFile() {
  image.save("drawing.png");  // Save the image file
  
  // Show message to tell the image has been saved
  String title = "Image saved";
  String[] content = {"drawing.png has been saved."};
  showMessage(title, content);
}

// Subroutine to display the help message
void showHelp(boolean startUp) {
  // Show message 
  String title = (startUp ? "Welcome to TinyDraw" : "Help");
  String[] content = {"Use the mouse to draw on the screen. Hold the left mouse button",
                      "to draw or the right mouse button to erase.",
                      "To clear the entire screen press C.",
                      "Press M to switch between draw or pick mode.",
                      "Use the arrow keys to change the RGB color values, right and left",
                      "change which value your changing, up and down change the value.",
                      "Scrolling the mouse wheel will change the pencil size",
                      "To save your image press S, to load an image press O",
                      "To enable or disable the HUD press V and press H to show this",
                      "help message again.",
                      "",
                      "TinyDraw was made by Thomas Bruninx using Processing.",
                      "Source Code available at https://github.com/thomasbruninx.",
                      "",
                      "Thanks for using TinyDraw",
                      "",
                      "",
                      "(Current version " + BUILD + ")"};
                      
  showMessage(title, content);
}