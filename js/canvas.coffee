class Canvas
	constructor: -> @shapes = []
	clear: -> @shapes = []
	addShape: (shape) -> @shapes.push(shape)
	@fromJSON: (json_string) ->
		json = JSON.parse json_string
		canvas = new this
		for shape in json.shapes
			switch shape.type
				when "Circle" then canvas.addShape Circle.fromJSON shape
				when "Line" then canvas.addShape Line.fromJSON shape
		canvas
	@boat = '{"shapes":[{"points":[{"x":5,"y":592},{"x":795,"y":593}],"color":"#0000FF","type":"Line"},{"points":[{"x":8,"y":586},{"x":795,"y":588}],"color":"#0000FF","type":"Line"},{"points":[{"x":7,"y":581},{"x":793,"y":584}],"color":"#0000FF","type":"Line"},{"points":[{"x":10,"y":577},{"x":793,"y":580}],"color":"#0000FF","type":"Line"},{"points":[{"x":791,"y":576},{"x":11,"y":574}],"color":"#0000FF","type":"Line"},{"points":[{"x":11,"y":570},{"x":793,"y":574}],"color":"#0000FF","type":"Line"},{"points":[{"x":12,"y":568},{"x":790,"y":570}],"color":"#0000FF","type":"Line"},{"points":[{"x":790,"y":566},{"x":11,"y":565}],"color":"#0000FF","type":"Line"},{"points":[{"x":11,"y":560},{"x":788,"y":562}],"color":"#0000FF","type":"Line"},{"points":[{"x":789,"y":558},{"x":13,"y":556}],"color":"#0000FF","type":"Line"},{"points":[{"x":13,"y":549},{"x":789,"y":554}],"color":"#0000FF","type":"Line"},{"points":[{"x":789,"y":546},{"x":19,"y":544}],"color":"#0000FF","type":"Line"},{"points":[{"x":17,"y":539},{"x":788,"y":542}],"color":"#0000FF","type":"Line"},{"points":[{"x":54,"y":406},{"x":103,"y":537}],"color":"#000000","type":"Line"},{"points":[{"x":102,"y":537},{"x":681,"y":538}],"color":"#000000","type":"Line"},{"points":[{"x":681,"y":538},{"x":742,"y":407}],"color":"#000000","type":"Line"},{"points":[{"x":742,"y":407},{"x":55,"y":412}],"color":"#000000","type":"Line"},{"points":[{"x":395,"y":409},{"x":390,"y":85}],"color":"#000000","type":"Line"},{"points":[{"x":399,"y":89},{"x":404,"y":410}],"color":"#000000","type":"Line"},{"points":[{"x":396,"y":91},{"x":404,"y":407}],"color":"#854700","type":"Line"},{"points":[{"x":394,"y":92},{"x":399,"y":413}],"color":"#854700","type":"Line"},{"points":[{"x":394,"y":93},{"x":398,"y":407}],"color":"#854700","type":"Line"},{"points":[{"x":397,"y":88},{"x":402,"y":404}],"color":"#854700","type":"Line"},{"points":[{"x":391,"y":103},{"x":267,"y":101}],"color":"#B00000","type":"Line"},{"points":[{"x":267,"y":101},{"x":269,"y":268}],"color":"#B00000","type":"Line"},{"points":[{"x":269,"y":267},{"x":395,"y":264}],"color":"#B00000","type":"Line"},{"points":[{"x":269,"y":103},{"x":391,"y":263}],"color":"#B00000","type":"Line"},{"points":[{"x":270,"y":269},{"x":389,"y":107}],"color":"#B00000","type":"Line"},{"points":[{"x":626,"y":473},{"x":668,"y":487}],"color":"#17AAFF","type":"Circle"},{"points":[{"x":516,"y":474},{"x":566,"y":478}],"color":"#17AAFF","type":"Circle"},{"points":[{"x":396,"y":476},{"x":456,"y":472}],"color":"#17AAFF","type":"Circle"},{"points":[{"x":281,"y":476},{"x":330,"y":476}],"color":"#17AAFF","type":"Circle"},{"points":[{"x":175,"y":474},{"x":226,"y":477}],"color":"#17AAFF","type":"Circle"}]}'

class CanvasView
	constructor: (canvas_element_id) ->
		@canvas = $("#" + canvas_element_id)
		@ctx = @canvas[0].getContext("2d")
		@height = @canvas.attr("height")
		@width = @canvas.attr("width")

	put_pixel: (p1) =>
		@ctx.fillRect(p1.x, p1.y, 1, 1)
	render: (shapes) ->
		for shape in shapes
			@ctx.fillStyle = shape.color
			shape.render @put_pixel
	clear: ->
		@ctx.clearRect(0, 0, @canvas[0].width, @canvas[0].height)
	update_coordinates: (e) ->
		x = e.pageX - this.offsetLeft
		y = e.pageY - this.offsetTop
		$("#coordinates").html(y + " ," + x)

class CanvasController
	constructor: (@model, @view) ->
		@point_stack = []
		@active_button = null
		@view.canvas.bind "mousemove", @view.update_coordinates
		@view.canvas.bind "click", @canvas_click
		@view.canvas.bind "mousedown", @canvas_mousedown
		@view.canvas.bind "mouseup", @canvas_mouseup
		$("#reflection-x").bind "click", => @reflection("x")
		$("#reflection-y").bind "click", => @reflection("y")
		$("#clear").bind "click", @canvas_clear
		$("input.color").bind "change", @color_pick
		$("#undo").bind "click", @undo_click
		$("#boat").bind "click", @boat_click
		$("#json").bind "keyup", @json_keyup

		@bind_menubar_buttons()
		@draggable_actions = [
			$("#translation")[0],
			$("#line")[0],
			$("#circle")[0],
			$("#scaling")[0],
			$("#rotation")[0],
			$("#shearing-x")[0],
			$("#shearing-y")[0]
		]

	bind_menubar_buttons: ->
		$("#menubar > button").each (index, element) =>
			$(element).click (e) =>
				@active_button = e.target
				@point_stack = []

	refresh: ->
		@view.clear()
		@view.render @model.shapes
		$("#json").val(JSON.stringify @model)

	undo_click: =>
		for shape in @model.shapes
			for point in shape.points
				point.undo()
		@refresh()

	boat_click: =>
		$("#json").val(Canvas.boat)
		@json_keyup()

	json_keyup: =>
		@model = Canvas.fromJSON $("#json").val()
		@view.clear()
		@view.render @model.shapes
	canvas_mousedown: (e) => 
		if @active_button in @draggable_actions
			@point_stack.push new CursorPoint(e)

	color_pick: (e) =>
		Shape.color = "#" + e.target.value

	canvas_mouseup: (e) =>
		if @active_button in @draggable_actions
			@point_stack.push new CursorPoint(e)
			if @point_stack.length == 2
				p2 = @point_stack.pop()
				p1 = @point_stack.pop()
				dx = p2.x - p1.x
				dy = p2.y - p1.y  
				switch @active_button
					when $("#line")[0]
						@model.addShape new Line [p1, p2]
					when $("#circle")[0]
						@model.addShape new Circle [p1, p2]
					when $("#translation")[0]
						for shape in @model.shapes
							for point in shape.points
								point.translate(dx, dy)
					when $("#scaling")[0]
						for shape in @model.shapes
							for point in shape.points
								point.scale 1 + dx / @view.width, 1 + dy / @view.height
					when $("#rotation")[0]
						theta = -Math.atan dy/dx
						for shape in @model.shapes
							for point in shape.points
								point.pivot_rotate theta, p1

					when $("#shearing-x")[0]
						for shape in @model.shapes
							for point in shape.points
								if dx != 0 then point.shear "x", dx / @view.width
					when $("#shearing-y")[0]
						for shape in @model.shapes
							for point in shape.points
								if dy != 0 then point.shear "y", dy / @view.height
				@refresh()

	canvas_clear: =>
		@model.clear()
		@view.clear()
		$("#json").val("")

	reflection: (axis) =>
		canvas_max_point = new Point @view.width, @view.height
		for shape in @model.shapes
			for point in shape.points
				point.reflect axis, canvas_max_point
		@refresh()

class Point
	constructor: (@x, @y) -> 
	@fromJSON: (json) -> new Point(json.x, json.y)	
	equals: (point) ->
		if @x == point.x and @y == point.y then true else false
	distance: (another_point) ->
		dx = another_point.x - @x
		dy = another_point.y - @y
		Math.round Math.sqrt(dx * dx + dy * dy)
	translate: (Tx, Ty) ->
		@x += Tx
		@y += Ty
		@undo = -> @translate(-Tx, -Ty)
	scale: (Sx, Sy) ->
		@x *= Sx
		@y *= Sy
		@undo = -> @scale(1/Sx, 1/Sy)
	rotate: (theta) ->
		@x = @x * Math.cos(theta) - @y * Math.sin(theta)
		@y = @x * Math.sin(theta) + @y * Math.cos(theta)
		@undo = -> @rotate(-theta) 
	pivot_rotate: (theta, pivot) ->
		theta = -theta
		p = new Point(
			(@x - pivot.x) * Math.cos(theta) - (@y - pivot.y) * Math.sin(theta) + pivot.x,
			(@x - pivot.x) * Math.sin(theta) + (@y - pivot.y) * Math.cos(theta) + pivot.y
			)
		@x = p.x
		@y = p.y
		@undo = -> @pivot_rotate(theta, pivot)
	reflect: (axis, canvas_max_point) ->
		switch axis
			when "x" then @y = canvas_max_point.y - @y
			when "y" then @x = canvas_max_point.x - @x
		@undo = -> @reflect(axis, canvas_max_point)
	shear: (axis, k) ->
		switch axis
			when "x" then @x += k * @y
			when "y" then @y += k * @x
		@undo = -> @shear(axis, -k)

class CursorPoint extends Point
	constructor: (e) ->
		super(e.pageX - e.target.offsetLeft, e.pageY - e.target.offsetTop)

class JSONable
	constructor: -> 
		@type = @constructor.name

class Shape extends JSONable
	constructor: (@points, @color = "#000000") ->
		@color = Shape.color
		super
	@color: "#000000"	
	@fromJSON: (json) ->
		Shape.color = json.color
		new this [Point.fromJSON(json.points[0]), Point.fromJSON(json.points[1])]

class Line extends Shape
	render: (draw_pixel_callback) ->
		p0 = new Point @points[0].x, @points[0].y
		p1 = new Point @points[1].x, @points[1].y
		p0.x = Math.round(p0.x)
		p0.y = Math.round(p0.y)
		p1.x = Math.round(p1.x)
		p1.y = Math.round(p1.y)
		dx = Math.abs(p1.x - p0.x)
		sx = if p0.x < p1.x then 1 else -1 
		dy = -Math.abs(p1.y - p0.y)
		sy = if p0.y < p1.y then 1 else -1
		err = dx + dy

		while (true) 
			draw_pixel_callback(new Point(p0.x, p0.y))
			if (p0.x == p1.x && p0.y == p1.y) then break
			e2 = 2 * err
			if (e2 >= dy)
				err += dy
				p0.x += sx
			if (e2 <= dx)
				err += dx
				p0.y += sy

class Circle extends Shape
	render: (draw_pixel_callback) ->
		center = @points[0]
		perimeter = @points[1]
		r = Math.sqrt(Math.pow(perimeter.x - center.x, 2) + Math.pow(perimeter.y - center.y, 2))
		x = -r
		y = 0
		err = 2 - 2 * r
		block = ->
			draw_pixel_callback new Point(center.x - x, center.y + y)
			draw_pixel_callback new Point(center.x - y, center.y - x)
			draw_pixel_callback new Point(center.x + x, center.y - y)
			draw_pixel_callback new Point(center.x + y, center.y + x)
			r = err
			if r > x then err += ++x * 2 + 1
			if r <= y then err += ++y * 2 + 1
		block() while (x < 0)
	
class PointTest
	constructor: ->
		for test in [@distance, @pivot_rotate, @equals, @shear, @reflect, @undo]
			test()
	distance: ->
		p1 = new Point 100,100
		p2 = new Point 300,300
		if p1.distance(p2) != 283 then console.log "Failed test - distance"
	pivot_rotate: ->
		p1 = new Point 100,100
		p2 = new Point 300,100
		d1 = p1.distance p2
		for p in [p1, p2]
			p.pivot_rotate(-Math.PI/4, p1)
		if p1.distance(p2) isnt d1 then console.log "Failed test - pivot_rotate"
	shear: ->
		points = [new Point(0,0), new Point(100,0), new Point(0,50), new Point(100,50)]
		for point in points
			point.shear "x", 0.2
		if !points[0].equals(new Point(0,0)) or
			!points[1].equals(new Point(100,0)) or
			!points[2].equals(new Point(10,50)) or
			!points[3].equals(new Point(110,50)) then console.log "failed test - shear"
	equals: ->
		p1 = new Point(1,2)
		p2 = new Point(3,4)
		if !(p1.equals p1) or p1.equals p2 then console.log "failed test - equals"
	reflect: ->
		p1 = new Point 200,300
		p1.reflect("y", new Point(800,600))
		p2 = new Point 600,300
		if p1.equals(p2) isnt true then error = "failed test - shear x"
	undo: ->
		p1 = new Point 100,100
		p2 = new Point 100,100
		p1.translate 10,10
		p1.undo()
		if !(p1.equals p2) then console.log "failed test - undo translate"

# Main
$ -> 
	canvasApp = new CanvasController(new Canvas, new CanvasView "canvas")
	test = new PointTest
	canvasApp.view.render canvasApp.model.shapes