function Circle(center_point, preimeter_point) {
	this.center_point = center_point;
	this.perimeter_point = preimeter_point;

	this.render = function(draw_pixel_callback) {
		var perimeter = this.perimeter_point,
			center = this.center_point,
			r = Math.sqrt(Math.pow(perimeter.x - center.x, 2) + Math.pow(perimeter.y - center.y, 2)),
			x = -r,
			y = 0,
			err = 2 - 2 * r;
		do {
			draw_pixel_callback(new Point(center.x - x, center.y + y)); /*   I. Quadrant */
			draw_pixel_callback(new Point(center.x - y, center.y - x)); /*  II. Quadrant */
			draw_pixel_callback(new Point(center.x + x, center.y - y)); /* III. Quadrant */
			draw_pixel_callback(new Point(center.x + y, center.y + x)); /*  IV. Quadrant */
			r = err;
			if (r > x) err += ++x * 2 + 1; /* e_xy+e_x > 0 */
			if (r <= y) err += ++y * 2 + 1; /* e_xy+e_y < 0 */
		} while (x < 0);
	}
}
