import peasy.*;

PeasyCam cam;
Table table;
ArrayList<GothicNode> nodes = new ArrayList<GothicNode>();
int mode = 1; // 1: ResNet (Visual), 2: CLIP (Semantic)
PFont font;

void setup() {
  size(1200, 800, P3D);
  // PeasyCam for 3D navigation: Left drag to rotate, Scroll to zoom
  cam = new PeasyCam(this, 800);
  
  // Load the extracted features
  table = loadTable("vector_comparison_results.csv", "header");
  if (table == null) {
    println("Error: Cannot find 'vector_comparison_results.csv'. Please check the data folder.");
    exit();
  }

  for (TableRow row : table.rows()) {
    nodes.add(new GothicNode(row));
  }
  
  font = createFont("Arial", 16);
  textFont(font);
}

void draw() {
  background(10); // Darker background for "Gothic" atmosphere
  
  // Draw the spatial bounds
  drawBoundingBox();

  // Draw data nodes
  for (GothicNode n : nodes) {
    n.update(mode);
    n.display();
  }
  
  // HUD: Display Current Mode Only
  cam.beginHUD();
  fill(200);
  textSize(18);
  String modeText = (mode == 1) ? "Latent Space A: ResNet (Visual Formalism)" : "Latent Space B: CLIP (Semantic Narrative)";
  text(modeText, 40, 50);
  cam.endHUD();
}

void drawBoundingBox() {
  strokeWeight(0.5);
  stroke(60); // Subtle grid lines
  noFill();
  box(600); 
}

void keyPressed() {
  // Use Spacebar to toggle between models
  if (key == ' ') {
    if (mode == 1) mode = 2;
    else mode = 1;
  }
}

class GothicNode {
  String fileName;
  PVector resPos, clipPos, currentPos;
  PImage img;
  boolean isLoaded = false;
  float nodeSize = 6;

  GothicNode(TableRow row) {
    fileName = row.getString("file");
    
    // Mapping 0-1 coordinates to 3D space (-300 to 300)
    float rx = (row.getFloat("res_x") - 0.5) * 600;
    float ry = (row.getFloat("res_y") - 0.5) * 600;
    float rz = random(-150, 150); // Adding depth to the ResNet layer
    resPos = new PVector(rx, ry, rz);

    float cx = (row.getFloat("clip_x") - 0.5) * 600;
    float cy = (row.getFloat("clip_y") - 0.5) * 600;
    float cz = random(-150, 150); // Adding depth to the CLIP layer
    clipPos = new PVector(cx, cy, cz);
    
    currentPos = resPos.copy();
  }

  void update(int mode) {
    PVector target = (mode == 1) ? resPos : clipPos;
    // Linear Interpolation (lerp) for smooth transformation animation
    currentPos.lerp(target, 0.08); 
  }

  void display() {
    pushMatrix();
    translate(currentPos.x, currentPos.y, currentPos.z);
    
    // Visual encoding: Blue for Form, Red for Meaning
    if (mode == 1) fill(70, 130, 255, 180); 
    else fill(255, 70, 70, 180);           
    
    noStroke();
    sphere(nodeSize / 2); 
    
    // Hover Interaction: Loads and displays image if mouse is near
    if (dist(mouseX, mouseY, screenX(0,0,0), screenY(0,0,0)) < 12) {
      if (!isLoaded) {
          img = loadImage(fileName);
          if (img != null) img.resize(200, 0);
          isLoaded = true;
      }
      if (img != null) {
        // Display Image Preview in 3D Space
        image(img, 15, 15);
        fill(255);
        textSize(12);
        text(fileName, 15, img.height + 35);
        stroke(255, 100);
        line(0, 0, 0, 15, 15, 0); // Connector line
      }
    }
    popMatrix();
  }
}
