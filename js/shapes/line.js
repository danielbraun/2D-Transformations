function Line(p0, p1) {
	this.p0 = p0;
	this.p1 = p1;

	this.render = function(draw_pixel_callback) {
		var p0 = this.p0;
		var p1 = this.p1;
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
			draw_pixel_callback(new Point(p0.x, p0.y));
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
	}
}
