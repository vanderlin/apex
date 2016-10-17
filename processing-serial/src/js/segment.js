'use strict';

var Segment = function() {

	var pts = [];
	var dir = 1;
	var count = 0;
	var isDoneDrawing = false;
	var osc = new Tone.Oscillator({
		"volume" : 1
	}).toMaster()
	var prevPnt = null;
	var pLength = 0;
	var vLength = 0;
	var color = 255;
	var startCountTime = 0;
	var jump = {x:0, y:0};
	var delta = 0;
	this.draw = function() {
		delta += 0.1;
		vLength = lerp(pLength, vLength, 0.92);
		if(isDoneDrawing && pts.length>2) {

			for (var i = 1; i < pts.length; i++) {
				var a = pts[i];
				var b = pts[i-1];
				var v = {x:a.x-b.x, y:a.y-b.y};
				var length = Math.sqrt(v.x*v.x + v.y*v.y);
				pts[i].vel =length > 0 ? {x:v.x/length, y:v.y/length} : v;
			}
			for (var i = pts.length - 1; i > 0; i--) {
					var a = pts[i];
					var b = pts[i-1];
					var v = {x:a.x-b.x, y:a.y-b.y};
					var length = Math.sqrt(v.x*v.x + v.y*v.y);
					var nv = length > 0 ? {x:v.x/length, y:v.y/length} : v;
					var perp = {x:-(v.y/length), y:v.x/length};	
				

					//a.x += a.vel.x;// - (nv.x * perp.x) / length;
					//a.y += a.vel.y + 2;// - (nv.y * perp.y) / length;

					//a.x = b.x + (nv.x * 3.0) / length;
					//a.y = b.y + (nv.y * 3.0) / length;
					//pts[i].x = pts[i-1].x;
					//pts[i].y = pts[i-1].y;
				// pts[i].x = pts[i-1].x + (nv.x * 3) / length;
				// pts[i].y = pts[i-1].y + (nv.y * 3) / length;
			}
			
			pts[0].x = pts[pts.length-1].x - jump.x;
			pts[0].y = pts[pts.length-1].y - jump.y;
			
			//pts[0].radius = pts[pts.length-1].radius;// - jump.x;
			//pts[0].radius = pts[pts.length-1].radius;// - jump.y;
			//pts[0].x = pts[pts.length-1].x - jump.x;
			//pts[0].y = pts[pts.length-1].y - jump.y;
			
			/*
			for (var i = 1; i < pts.length; i++) {
				var a = pts[i];
				var b = pts[i==0?2:i-1];
				var v = {x:a.x-b.x, y:a.y-b.y};
				var length = Math.sqrt(v.x*v.x + v.y*v.y);
				var nv = length > 0 ? {x:v.x/length, y:v.y/length} : v;
				

				var scl = 2.10;
				nv.x *= scl;
				nv.y *= scl;

				a.x += nv.x;
				a.y += nv.y;
			}
			*/
			this.renderLine(count);
		}
		else {
			this.renderLine(pts.length);
		}
	}

	this.renderLine = function(c) {
		
		if(pts.length < 3)  return;

		stroke(color);
		noFill();
		for (var i = 1; i < pts.length-1; i++) {
			line(pts[i-1].x, pts[i-1].y, pts[i].x, pts[i].y);
			line(	pts[i].x, pts[i].y, 
					pts[i].x + pts[i].vel.x, 
					pts[i].y + pts[i].vel.y);

		}
		/*
		beginShape(TRIANGLE_STRIP);
		for (var i = 1; i < pts.length-1; i++) {
			var p = pts[i];
			p.update();
			var a = pts[i];
			var b = pts[i+1];
			
			var v = {x:a.x-b.x, y:a.y-b.y};
			var d = v;
			var length = Math.sqrt(v.x*v.x + v.y*v.y);

			var nv = length > 0 ? {x:v.x/length, y:v.y/length} : v;

			if(length > 0) {
				d = {x:-(v.y/length), y:v.x/length};	
			}

			var scl = 1.10;

			//a.x = (a.x + b.x - nv.x) * 0.4;
			//a.y = (a.y + b.y - nv.y) * 0.4;
			
			
			//p.radiusDes = c == i ? (p.length * 4.0) : a.length;
			if(c == i) {
				p.colorDes = 0;
				p.color = 0;
			}
			else {
				p.colorDes = 255;
			}

			d.x *= p.radius;
			d.y *= p.radius;
			//ellipse(pts[i].x, pts[i].y, 2, 2);	
			//line(a.x, a.y, b.x, b.y);
			// strip
			vertex(a.x - d.x, a.y - d.y); 
			vertex(a.x + d.x, a.y + d.y); 
			//line(a.x, a.y, a.x - d.x, a.y - d.y);
		}
		endShape();
		*/
	}

	this.add = function(x, y) {
		var timestamp = new Date().getTime();
		var p = {
			x:x, 
			y:y, 
			ox:x, 
			oy:y, 
			timestamp:timestamp, 
			count:0, 
			length:1, 
			radius:0, 
			radiusDes:0, 
			color:0,
			colorDes:255,
			vel:{x:0, y:0},
			update: function() {
				var t = 0.89;
				this.color = (1-t) * this.colorDes + t * this.color;
				//this.radius = (1-t) * this.radiusDes + t * this.radius;
		}};

		if(prevPnt) {
			var v = {x:x-prevPnt.x, y:y-prevPnt.y};
			var length = Math.sqrt(v.x*v.x + v.y*v.y);
			if(length < 4) length = 4;
			if(length > 10) length = 10;
			pLength = length;
			p.length = vLength;
			p.radius = p.length; 
		}
		pts.push(p);
		prevPnt = p;
	}

	this.end = function() {
		count = 0;
		startCountTime = millis();
		isDoneDrawing = true;

		jump.x = pts[pts.length-1].x - pts[0].x; 
		jump.y = pts[pts.length-1].y - pts[0].y;
		
		// calc
		for (var i = 0; i < pts.length-1; i++) {
			var a = pts[i];
			var b = pts[i+1];
			var v = {x:a.x-b.x, y:a.y-b.y};
			var length = Math.sqrt(v.x*v.x + v.y*v.y);
			var nv = length > 0 ? {x:v.x/length, y:v.y/length} : v;
			pts[i].vel = nv;
		}
			
		//osc.start();
	}

	this.destroy = function() {
		osc.stop();
	}
	
};
module.exports = Segment;