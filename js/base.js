$(function() {
	$("#canvas").mousemove(function(e) {
		x = e.pageX - this.offsetLeft;
		y = e.pageY - this.offsetTop;
		$("#coordinates").html(y + " ," + x);
	});

	var myCanvas = new Canvas($("#canvas")[0]);

	$("#clear").click(function() {
		myCanvas.clear();
	});

	$("#polygon_edges, #curve_edges").change(function() {
		$(this).attr("title", $(this).val());
	});
});

function Canvas(aCanvas) {
	this.canvas = aCanvas;
	var self = this;
	var pointStack = [];
	var activeButton = null;

	$("#menubar > button").each(function() {
		$(this).click(function() {
			activeButton = $(this)[0];
			pointStack = [];
		});
	});

	$("#" + this.canvas.getAttribute("id")).click(function(e) {
		pointStack.push(new Point(e.pageX - this.offsetLeft, e.pageY - this.offsetTop));

		// line
		if (activeButton == $("#line")[0] && pointStack.length == 2) {
			self.drawLine(pointStack.pop(), pointStack.pop());
		};

		// circle
		if (activeButton == $("#circle")[0] && pointStack.length == 2) {
			var p1 = pointStack.pop(),
				p2 = pointStack.pop();
			self.drawCircle(p2, p1);
		}

		// regular polygon
		if (activeButton == $("#polygon")[0] && pointStack.length == 2) {
			var p1 = pointStack.pop(),
				p2 = pointStack.pop();
			self.drawRegularPolygon(p2, p1, $("#polygon_edges").val());
		}

		// bezier curve
		if (activeButton == $("#bezier")[0] && pointStack.length == 4) {
			p4 = pointStack.pop();
			p3 = pointStack.pop();
			p2 = pointStack.pop();
			p1 = pointStack.pop();
			self.drawBezierCurve(p1, p2, p3, p4, $("#curve_edges").val());
		}
	});
}

Canvas.prototype.clear = function() {
	this.canvas.getContext("2d").clearRect(0, 0, this.canvas.width, this.canvas.height);
};


function Point(x, y) {
	this.x = x;
	this.y = y;
}

Canvas.prototype.drawPixel = function(p1) {
	var ctx = this.canvas.getContext("2d");
	ctx.fillstyle = "#FF";
	ctx.fillRect(p1.x, p1.y, 1, 1);
};

Canvas.prototype.drawLine = function(p0, p1) {
	p0.x = Math.round(p0.x);
	p0.y = Math.round(p0.y);
	p1.x = Math.round(p1.x);
	p1.y = Math.round(p1.y);

	var dx = Math.abs(p1.x - p0.x),
		sx = p0.x < p1.x ? 1 : -1,
		dy = -Math.abs(p1.y - p0.y),
		sy = p0.y < p1.y ? 1 : -1,
		err = dx + dy,
		e2;

	while (true) {
		this.drawPixel(new Point(p0.x, p0.y));
		if (p0.x == p1.x && p0.y == p1.y) break;
		e2 = 2 * err;
		if (e2 >= dy) {
			err += dy;
			p0.x += sx;
		}
		if (e2 <= dx) {
			err += dx;
			p0.y += sy;
		}
	}
};

Canvas.prototype.drawCircle = function(center, perimeter) {
	var r = Math.sqrt(Math.pow(perimeter.x - center.x, 2) + Math.pow(perimeter.y - center.y, 2));
	var x = -r,
		y = 0,
		err = 2 - 2 * r;
	do {
		this.drawPixel(new Point(center.x - x, center.y + y)); /*   I. Quadrant */
		this.drawPixel(new Point(center.x - y, center.y - x)); /*  II. Quadrant */
		this.drawPixel(new Point(center.x + x, center.y - y)); /* III. Quadrant */
		this.drawPixel(new Point(center.x + y, center.y + x)); /*  IV. Quadrant */
		r = err;
		if (r > x) err += ++x * 2 + 1; /* e_xy+e_x > 0 */
		if (r <= y) err += ++y * 2 + 1; /* e_xy+e_y < 0 */
	} while (x < 0);
};

Canvas.prototype.drawRegularPolygon = function(center, perimeter, n) {
	var r = Math.sqrt(Math.pow(perimeter.x - center.x, 2) + Math.pow(perimeter.y - center.y, 2)),
		a = Math.atan2(perimeter.y - center.y, perimeter.x - center.x),
		i, lastx, lasty;
	for (i = 1; i <= n; i++) {
		lastx = perimeter.x;
		lasty = perimeter.y;
		a = a + Math.PI * 2 / n;
		perimeter.x = Math.round(center.x + r * Math.cos(a));
		perimeter.y = Math.round(center.y + r * Math.sin(a));
		this.drawLine(new Point(lastx, lasty), perimeter);
	}
};

Canvas.prototype.drawBezierCurve = function(P0, P1, P2, P3, edges) {
	var lastx = 0,
		lasty = 0,
		step = 1 / edges,
		current_point, next_point;
	for (var i = 0; i < 1; i = i + step) {
		current_point = new BezierCurvePoint(P0, P1, P2, P3, i);
		next_point = new BezierCurvePoint(P0, P1, P2, P3, i + step);
		this.drawLine(
		new Point(current_point.x, current_point.y), new Point(next_point.x, next_point.y));
	};

};

function B0(t) {
	return t * t * t // 3t^3
}

function B1(t) {
	return 3 * t * t * (1 - t) // -3t^3+3t^2
}

function B2(t) {
	return 3 * t * (1 - t) * (1 - t) // 3t^3 - 6t^2 + 3t
}

function B3(t) {
	return (1 - t) * (1 - t) * (1 - t) // -3t^3 + 3t^2 - 3t + 1
}

function BezierCurvePoint(P0, P1, P2, P3, percent) {
	return new Point(
	P0.x * B0(percent) + P1.x * B1(percent) + P2.x * B2(percent) + P3.x * B3(percent), P0.y * B0(percent) + P1.y * B1(percent) + P2.y * B2(percent) + P3.y * B3(percent));
}
