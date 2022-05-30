// scanning pixels in block square of size 'pixelSize', per column, per row
// sampling rgb color per pixel, adding until entire block is scanned
// taking average rgb => all rgb values added / amount of pixels in block => sum rgbvalues/(pixelsize)^2
// comparing this average color to color palette, the nearest rgb value in palette using dist()
// checking which index number contains nearest value
//
//Color Depth : 8-bit (256 colors)

//Game uses 129-256 colors.
// todo:
// color sky
// fade background (distance)
// integrate webcam script
// automatic image resize fr cam stream
//
//                                                 ///
/////                                         ///////
PImage img;
PrintWriter output;
int pixelSize = 4;
int saturationFac =1;  // 1 is normal. 
int partImage;
float h;
float s;
float b;
int alpha;


float hT; // temp rgb
float sT;
float bT;

float r; 
float g;
//float b;


float d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15;
int [] colors = {#000000, #FFFFFF, #b12c2c, #B4AFAD, #bc9463, #1a8236, #a8a39e, #485189, #2a2a2a, #2894c5, #2894c5, #542e00, #542e00, #383534};   // these values are with d1-dx

void setup() {
  size(1008,756 );
  noStroke();

  output = createWriter("values.txt"); 
  partImage = width*(height-20);// must be in setup, otherwise 0x0

  img = loadImage("sample2.jpg");
  img.resize(width, height);
  image (img, 0, 0);


  filter6(); // sky filter, place before cheqflag.png and other filters

  filter1(); // desaturate  
  filter3(); // increase brightness
  filter2();// contrast S/B shift
  //filter4(); // x bit filter (discriminated RGB values)

  //place befor last filter bec. it doesn't need all filters.
  img = loadImage("cheqflag.png");
  img.resize(260, 260);
  image (img, -50, -30);

  filter5(); // brightness discrimination _ dark accents
  background(0);

  pixelize();

  //overlay();
  //UI();
  //outputFLush() ;

  UI();
}


void draw() {
  //background(img);// it is possible to set img as background
}


// desaturate
void  filter1() {
  loadPixels();//
  colorMode(HSB, 360, 2, 100); // saturation scale, leave at 100 for direct control

  for (int i = 0; i < partImage; i++) {

    h = round(hue(pixels[i]));
    s = round(saturation(pixels[i])*saturationFac);
    b = round(brightness(pixels[i]));
    //      output.println("h,s,b:"+h+","+s+","+b);
    //      println("h,s,b:--"+h+"--"+s+"--"+b);
    pixels[i]   = color(h, s, b);// saturation on level of 100
  }
  updatePixels();
}

// contrast    S/B shift
void  filter2() {
  loadPixels();//
  colorMode(HSB, 360, 100, 100); 

  for (int i = 0; i < partImage; i++) {

    h = round(hue(pixels[i]));
    s = round(saturation(pixels[i]));
    b = round(brightness(pixels[i]));

    // lower float number = higher contrast
    //values away from center
    if (s<50) {
      s=s*0.8f;
    } else {     
      s=100- ((100-s)*0.2f);
    }


    if (b<50) {
      b=b*0.8f;
    } else {     
      b=100- ((100-b)*0.2f);
    }

    // float vh = map(h, 0, 100, 0, 50);
    // float vs = map(s, 0, 100, 0, 50);
    // float vb = map(b, 0, 100, 0, 50);
    //// println (h, vs, vb);
    // pixels[i]   = color(50+vh, 50+vs, 50+vb);

    pixels[i]   = color(h, s, b);
    // pixels[i]   = color(h, 50,50); // try fixed values for s,b
  }
  updatePixels();
}

// increase brightness
void  filter3() {
  loadPixels();//
  colorMode(HSB, 360, 100, 100); // saturation scale, leave at 100 for direct control

  for (int i = 0; i < partImage; i++) {

    h = hue(pixels[i]);
    s = saturation(pixels[i]);
    b = brightness(pixels[i]);

    float bc =100-((100-b)*0.8f);// float changes brightness

    pixels[i]   = color(h, s, bc);// saturation on level of 100
  }
  updatePixels();
}

// x bit filter (discriminated RGB values)
void  filter4() {
  colorMode(RGB, 4, 4, 4);// 1,1,1 or  7,7,3 (256 combinations (8*8*4=256) ) is 8 bit. simple 8-bit quantization
  // colorMode(RGB, 4, 4, 4);//
  loadPixels();//
  for (int i = 0; i < partImage; i++) {

    r = round(red(pixels[i]));
    g = round(green(pixels[i]));
    b = round(blue(pixels[i]));
    //println("R,G,B",r,g,b);

    //if (r==0 && g==0 && b==0) { 
    //  r=0.3f; 
    //  g=0.3f; 
    //  b=0.3f;
    //}
    pixels[i]   = color(r, g, b); // try fixed values for s,b
  }
  updatePixels();
}


//brightness discrimination _ black/dark outlines
void  filter5() {
  colorMode(HSB, 360, 100, 100, 1);// 1,1,1 or  7,7,3 (256 combinations (8*8*4=256) ) is 8 bit. simple 8-bit quantization
  loadPixels();//
  for (int i = 0; i < partImage; i++) {

    h = round(hue(pixels[i]));
    s = round(saturation(pixels[i]));
    b = round(brightness(pixels[i]));

    //cutoff value
    if (b<24) {
      h=0;//black 0,0,100 - gray 0,0,10
      s=0;
      b=0;
      alpha=1;
    } else {
      //h=205;//blue 205,96,97 = brighter
      //s=96; // uncomment for opaque color
      //b=97; //
      alpha=1;//1 = transparent, but no other color must be assigned
    }//

    //h= 270; s=91; b=80;

    pixels[i]   = color(h, s, b, alpha); // try fixed values for s,b
  }
  updatePixels();
}

//sky filter ...sky pixels are brightest
//sky color: #0792fb    HSB:205,96,97  RGB:7,146,251
void  filter6() {
  colorMode(HSB, 360, 100, 100, 100);// 1,1,1 or  7,7,3 (256 combinations (8*8*4=256) ) is 8 bit. simple 8-bit quantization
  loadPixels();//
  for (int i = 0; i < partImage; i++) {

    h = hue(pixels[i]);
    s = saturation(pixels[i]);
    b = brightness(pixels[i]);

    //cutoff value
    //if (b<99){h=0;s=0;b=0;} else {h=0;s=0;b=100;}// black/white
    if (b<98.0f) {
      alpha=1;
    } else {
      h=205;
      s=96;
      b=97;
      alpha=0;
    }//


    pixels[i]   = color(h, s, b, alpha); // try fixed values for s,b
  }
  updatePixels();
}





void pixelize() {
  colorMode(HSB, 360, 100, 100);// using found values from game screenshots

  for (int row=0; row < height-pixelSize; row = row + pixelSize) {

    for (int column=0; column < width; column=column+pixelSize) {
      // println("____________line:",column);

      // horizontal scan pixelSize
      for (int y=0; y<pixelSize; y++) {
        // horizontal scan pixelSize
        for (int x=0; x<pixelSize; x++) {

          int pos = column+x+(width*y)+(width*row);
          //  float rT = pixels[pos];
          hT = hT + hue(pixels[pos]);
          sT = sT + saturation(pixels[pos]);
          bT = bT + brightness(pixels[pos]);

          //  pixels[pos] = color(h, s, b);
        }// end horizontal
      }// end vertical
      // average calc
      hT=hT/(pixelSize*pixelSize);
      sT=sT/(pixelSize*pixelSize);
      bT=bT/(pixelSize*pixelSize);

      //int [] colors = {#000000, #FFFFFF, #a49e9c, #0792fb, #1a8236, #2894c5, #238570, #a45b5a, #485189, #b12c2c, #bc9463, #b8bc5e};// RGB values to be applied
      int [] colors = {#000000, #FFFFFF, #a49e9c, #0792fb, #1a8236, #2894c5, #238570, #a45b5a, #485189, #b12c2c, #bc9463, #b8bc5e};// RGB values to be applied

      //  HSB color picked -  HSB values to compare
      d0 = dist (hT, sT, bT, 0, 0, 0  );//  black
      d1 = dist (hT, sT, bT, 0, 0, 100 );//   white
      d2 = dist (hT, sT, bT, 0, 4.9, 64.3);//   40.4 %   Nobel (Grey)
      d3 = dist (hT, sT, bT, 1, 97.2, 98.4 );//  32.5 %   Dodger Blue (Blue)
      d4 = dist (hT, sT, bT, 15, 80, 51);//10.4 %   Fruit Salad (Green)
      d5 = dist (hT, sT, bT, 33, 79.7, 77.3  );// 4.5 %   Cerulean (Blue)
      d6 = dist (hT, sT, bT, 63, 73.7, 52.2  );// 3.1 %   Deep Sea (Green)
      d7 = dist (hT, sT, bT, 136, 45.1, 64.3 );//  3.0 %   Copper Rust (Brown)
      d8 = dist (hT, sT, bT, 167, 47.4, 53.7  );// 2.7 %   Tory Blue (Blue)
      d9 = dist (hT, sT, bT, 199, 75.1, 69.4  );// 2.0 %   Carmine (Red)
      d10=  dist (hT, sT, bT, 206, 47.3, 73.7 );//  0.8 %   Fallow (Brown)
      d11=    dist (hT, sT, bT, 232, 50, 73.7   );//0.7 %   Olive Green (Green) 


      float [] values = {d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11};// 
      float v = min(values); // the minimum distance between  (hT, sT, bT) and color (of palette)

      //for (int t=0; t <colors.length; t++) { // checking which index had lowest value. This index has the nearest color, v

      //  if (values[t] == v) { //determines which value [t] is nearest the game palette
      //    //  println("value:", t);

      //    // blue sky : if checked position is above 1/3 image and is white. make blue
      //    //if (row < (0.3*height) && colors[t] == #FFFFFF) { 
      //    //  fill(#0792fb);
      //    //} else fill (colors[t]);

      //    colorMode(RGB, 255);// enable for palette quantization            
      //    fill (colors[t]); //// enable for palette quantization
      //  }
      //}

      fill (hT, sT, bT);// no filter, only pixelization if used, only use hsb mode. disable for palette quantization
     // square (column, row, pixelSize*0.98f);
     square (column, row, pixelSize);

      hT=0;
      sT=0;
      bT=0;
    }
  }
}

void overlay() {

  tint(255, 130);
  img = loadImage("xxxxx.jpg");
  img.resize(800, 450);
  image (img, 0, 0);
}

void UI() {
  colorMode(RGB, 255, 255, 255);
  PFont myFont;
  myFont = createFont("slkscr.ttf", 32);
  textFont(myFont);

  fill(255);
  rect (160, 30, 80, 24);

  fill (0);
  text("TIME            SCORE ", 162, 52);
  fill (255, 100, 0);
  text("TIME            SCORE ", 160, 50);


  fill (0);
  text("   80", 202, 52);
  fill (255, 200, 0);
  text("   80", 200, 50);

  myFont = createFont("slkscr.ttf", 28);
  textFont(myFont);

  fill (0);
  text("SPEED            STAGE 1 ", 162, 442);
  fill (255, 140, 0);
  text("SPEED            STAGE 1 ", 160, 440);

  // scale(1);
  //img = loadImage("cheqflag.png");
  //img.resize(100, 100);
  //image (img, 100, 120);
}


void keyPressed() {
  final int k = keyCode;

  if (k == 'S') saveFrame("Pix-###.png");
  // else         noLoop();
}

//void keyPressed() {
//  output.flush(); // Writes the remaining data to the file
//  output.close(); // Finishes the file
//  exit(); // Stops the program
//}
