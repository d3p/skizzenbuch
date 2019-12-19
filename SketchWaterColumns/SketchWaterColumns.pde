/* install library from https://github.com/d3p/algorithmic-cliches */

import de.hfkbremen.algorithmiccliches.fluiddynamics.*; 
import de.hfkbremen.algorithmiccliches.util.ArcBall; 

static final int X_SIZE = 1024 / 8;
static final int Y_SIZE = 768 / 8;
final Quad[][] mQuads = new Quad[X_SIZE][Y_SIZE];
WaterColumnSolver2 mWater;

void settings() {
  size(1024, 768, P3D);
}

void setup() {
  textFont(createFont("Courier", 11));
  /* create view */
  mWater = new WaterColumnSolver2(X_SIZE, Y_SIZE, 300);
  final float mCellSize = width / X_SIZE;
  for (int x = 0; x < mQuads.length; x++) {
    for (int y = 0; y < mQuads[x].length; y++) {
      mQuads[x][y] = new Quad();
      mQuads[x][y].a.set(x * mCellSize, y * mCellSize);
      mQuads[x][y].b.set(x * mCellSize + mCellSize, y * mCellSize);
      mQuads[x][y].c.set(x * mCellSize + mCellSize, y * mCellSize + mCellSize);
      mQuads[x][y].d.set(x * mCellSize, y * mCellSize + mCellSize);
    }
  }
  strokeWeight(0.1f);
}

void draw() {
  final float mDeltaTime = 1.0f / frameRate;
  /* step */
  final float mScaledDeltaTime = mDeltaTime * 10.0f;
  /* artificially speeding up the simulation */
  mWater.step(mScaledDeltaTime, 20);
  /* water interaction */
  final int mX = (int) (mouseX / (float) width * X_SIZE);
  final int mY = (int) (mouseY / (float) height * Y_SIZE);
  mWater.applyForce(mX, mY, 500.0f, mDeltaTime);
  final float mVolumePerSecond = 50.0f * mDeltaTime;
  if (keyPressed) {
    if (key == '+') {
      mWater.addVolume(mX, mY, mVolumePerSecond);
    }
    if (key == '-') {
      mWater.addVolume(mX, mY, -mVolumePerSecond);
    }
  }
  /* update quads from volume map */
  for (int x = 0; x < mQuads.length; x++) {
    for (int y = 0; y < mQuads[x].length; y++) {
      mQuads[x][y].a.z = mWater.volumemap()[x][y];
      mQuads[x][y].b.z = mWater.volumemap()[x_wrapped(x + 1)][y];
      mQuads[x][y].c.z = mWater.volumemap()[x_wrapped(x + 1)][y_wrapped(y + 1)];
      mQuads[x][y].d.z = mWater.volumemap()[x][y_wrapped(y + 1)];
    }
  }
  /* draw */
  background(255);
  directionalLight(126, 126, 126, 0, 0, -1);
  ambientLight(102, 102, 102);
  /* draw extra info */
  fill(0);
  noStroke();
  text("FPS      : " + (int) frameRate, 10, 12);
  text("VOLUME   : " + mWater.totalvolume(), 10, 24);
  /* view */
  rotateX(0.3 + 0.2*sin(frameCount / 360.0 * TWO_PI));
  rotateY(0.1 + 0.1*sin(frameCount / 360.0 * TWO_PI * 0.33));
  rotateZ(0.1);
  translate(50, -250, 0);
  translate(0, 0, -height);
  /* ground */
  fill(255, 127, 0);
  noStroke();
  rect(0, 0, width, height);
  /* water */
  fill(0, 127, 255, 191);
  stroke(31, 191, 255, 31);
  beginShape(TRIANGLES);
  scale(1, 1, 200);
  for (Quad[] mQuad : mQuads) {
    for (Quad q : mQuad) {
      vertex(q.a);
      vertex(q.b);
      vertex(q.c);
      vertex(q.a);
      vertex(q.c);
      vertex(q.d);
    }
  }
  endShape();
}

void vertex(PVector v) {
  vertex(v.x, v.y, v.z);
}

int x_wrapped(int x) {
  return (x + X_SIZE) % X_SIZE;
}

int y_wrapped(int y) {
  return (y + Y_SIZE) % Y_SIZE;
}

class Quad {
  final PVector a = new PVector();
  final PVector b = new PVector();
  final PVector c = new PVector();
  final PVector d = new PVector();
}
