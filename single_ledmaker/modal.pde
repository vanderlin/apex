class Modal {

	String text = "";
	float startTime = millis();
	float a = 0;
	float d = 0;
	float pauseTime = 1;
	boolean bDone = false;
	void setText(String text, float amount) {
		startTime = millis();
		this.text = text;
		d = 1;
		pauseTime = amount;
		bDone = false;
	}

	void draw() {

		if(bDone) return;

		a += (d-a) * 0.1;
		float t = (millis() - startTime) / 1000.0;

		if(t > 1) {
			d = 0;
			if(t > pauseTime) {
				println("pauseTime: "+pauseTime);
				bDone = true;
			}
		}
		// if(t > 5) {
		// 	d = 0;
		// }

		float w = 300;
		float h = 100;

		pushMatrix();
		translate((width-w)/2, (height-h)/2);
		noStroke();
		fill(0, a*250.0);
		rect(0, 0, w, h);

		fill(255, a*255.0);
		textAlign(CENTER);
		textSize(30);
		text(text, w/2, (h/2)+5);
		textSize(12);
		textAlign(LEFT);
		popMatrix();
	}
}