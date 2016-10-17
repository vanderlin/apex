
// ------------------------------------------------------------------------
PVector rotatePoint(PVector p, float a) {
    float mx = p.x;
    float my = p.y;
    float rx = mx*cos(a) - my*sin(a);
    float ry = mx*sin(a) + my*cos(a);
    return new PVector(rx, ry);
}

// ------------------------------------------------------------------------
PVector translatePoint(PVector p, float tx, float ty) {
    return new PVector(p.x+tx, p.y+ty);
}

// ------------------------------------------------------------------------
boolean insideRect(float tx, float ty, float x, float y, float w, float h) {
	return tx > x && tx < x+w && ty > y && ty < y+h;
}