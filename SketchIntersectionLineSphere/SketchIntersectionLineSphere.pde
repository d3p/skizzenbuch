/**
 * 'Intersection Of A Line And A Sphere'
 *
 * adapted from Paul Bourke ( source code for function by Iebele Abel )
 * [ http://local.wasp.uwa.edu.au/~pbourke/geometry/sphereline/ ]
 *
 */

float mRotation;

void setup() {
  size(1024, 768, P3D);
  smooth();
  noFill();
  sphereDetail(20);
}

void draw() {
  PVector p1 =  new PVector(mouseX - width / 2, mouseY - height / 2, -200);
  PVector p2 =  new PVector(mouseX - width / 2, mouseY - height / 2, 200);
  PVector mSphereCenter =  new PVector();
  PVector r1 =  new PVector();
  PVector r2 =  new PVector();
  final float mSphereRadius = 100;

  boolean mInterectionValid = intersectRayWithSphere(p1, p2, mSphereCenter, mSphereRadius, r1, r2);

  /* draw things */
  background(50);
  translate(width/2, height/2);

  mRotation += 1.0f / frameRate;
  rotateX(sin(mRotation * 0.5) * 0.33);
  rotateZ(cos(mRotation * 0.33) * 0.5);

  /* draw sphere */
  stroke(0, 127, 255, 127);
  noFill();
  pushMatrix();
  translate(mSphereCenter.x, mSphereCenter.y, mSphereCenter.z);
  sphere(mSphereRadius);
  popMatrix();

  /* draw ray */
  stroke(255, 127, 0, 127);
  noFill();
  line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);  

  /* draw points of intersection */
  if (mInterectionValid) {
    pushMatrix();
    fill(255);
    noStroke();
    translate(r1.x, r1.y, r1.z);
    sphere(5);
    popMatrix();
    pushMatrix();
    translate(r2.x, r2.y, r2.z);
    sphere(5);
    popMatrix();

    strokeWeight(4);
    stroke(255);
    line(r1.x, r1.y, r1.z, r2.x, r2.y, r2.z);
    strokeWeight(1);
  }
}


/*
 * Calculate the intersection of a ray and a sphere
 * The line segment is defined from p1 to p2
 * The sphere is of radius r and centered at sc
 * There are potentially two points of intersection given by
 * p = p1 + mu1 (p2 - p1)
 * p = p1 - mu2 (p2 - p1)
 * Return false if the ray doesn't intersect the sphere.
 */
boolean intersectRayWithSphere(PVector p1, PVector p2, PVector sc, float r, PVector r1, PVector r2)
{
  /*
   * note from dennis: 
   * the description of this intersection test is misleading in 
   * a way that it always returns two results even if the 
   * origin of the ray is inside of the sphere.
   * 'intersectStraightLineWithSphere' is less misleading better.
   */

  float a, b, c;
  float bb4ac;
  PVector dp = new PVector();
  final float EPS = 0.000001;

  dp.x = p2.x - p1.x;
  dp.y = p2.y - p1.y;
  dp.z = p2.z - p1.z;
  a = dp.x * dp.x + dp.y * dp.y + dp.z * dp.z;
  b = 2 * (dp.x * (p1.x - sc.x) + dp.y * (p1.y - sc.y) + dp.z * (p1.z - sc.z));
  c = sc.x * sc.x + sc.y * sc.y + sc.z * sc.z;
  c += p1.x * p1.x + p1.y * p1.y + p1.z * p1.z;
  c -= 2 * (sc.x * p1.x + sc.y * p1.y + sc.z * p1.z);
  c -= r * r;
  bb4ac = b * b - 4 * a * c;

  if (abs(a) < EPS || bb4ac < 0) {
    return false;
  }


  float mu1 = (-b + sqrt(bb4ac)) / (2 * a);
  float mu2 = (-b - sqrt(bb4ac)) / (2 * a);

  r1.set(dp);
  r1.mult(mu1);
  r1.add(p1);

  r2.set(dp);
  r2.mult(mu2);
  r2.add(p1);

  return true;
}
