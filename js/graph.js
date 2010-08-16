/* This notice must remain at all times.

Below the ---- line is the original notice.  I have since virtually
entirely rewritten this, but I have left it intact.  For now.

I have changed the name because it was too restricting.

-----------

graph.js
Copyright (c) Balamurugan S, 2005. sbalamurugan @ hotmail.com
Development support by Jexp, Inc http://www.jexp.com 

This package is free software. It is distributed under GPL - legalese removed, it means that you can use this for any purpose, but cannot charge for this software. Any enhancements you make to this piece of code, should be made available free to the general public! 

Latest version can be downloaded from http://www.sbmkpm.com

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

line.js provides a simple mechanism to draw line graphs. It  uses 
wz_jsgraphics.js  which is copyright of its author. 

Usage:
var g = new line_graph();
g.add("title1",value);
g.add("title2",value2);

g.render("canvas_name", "graph title");

//where canvas_name is a div defined INSIDE body tag 
<body>
<div id="canvas_name" style="overflow: auto; position:relative;height:300px;width:400px;"></div>


*/

function drawRect ( jg, x1, y1, x2, y2 ) {
	
	jg.drawLine ( x1, y1, x2, y1);
	jg.drawLine ( x2, y1, x2, y2);
	jg.drawLine ( x2, y2, x1, y2);
	jg.drawLine ( x1, y2, x1, y1);
}

function graph()
{
	this.xdata      = new Array();
	this.ydata      = new Array();
	this.ymax       = -9999999999999;	//	numbers need to be this big because if time it is 13 digits as milliseconds
	this.xmax       = -9999999999999;	//	numbers need to be this big because if time it is 13 digits as milliseconds
	this.ymin       =  9999999999999;	//	numbers need to be this big because if time it is 13 digits as milliseconds
	this.xmin       =  9999999999999;	//	numbers need to be this big because if time it is 13 digits as milliseconds

	this.width      = 800;		//	default width
	this.height     = 500;		//	default height
	this.titleColor = "black";
	this.lineColor  = "red";
	this.markColor  = "red";
	this.padding    = 20;
	this.left       = 30;
	this.bottom     = 40;
	this.labelSize  = 10;
	this.titleSize  = 16;
	this.xIsDate    = 0;
	this.Lines      = 1;
	this.Marks      = 1;
	
	this.add = function(xvalue, yvalue)
	{
		if ( this.xIsDate ) {
			var date  = new Date();
			var year  = String(xvalue).slice(0,4);
			var month = String(xvalue).slice(4,6);
			var day   = String(xvalue).slice(6,8);
			date.setFullYear ( year, month-1, day );
			xvalue = date.getTime();
		}
		this.xdata.push((xvalue));  
		this.ydata.push((yvalue));
	
		if(yvalue > this.ymax)
			this.ymax = (yvalue);
		if(xvalue > this.xmax)
			this.xmax = (xvalue);
		if(yvalue < this.ymin)
			this.ymin = (yvalue);
		if(xvalue < this.xmin)
			this.xmin = (xvalue);
	}

	this.render = function(canvas, title)
	{
		var jg = new jsGraphics(canvas);
		var padding = this.padding;
		var left    = this.left;
		var bottom  = this.bottom;
		var ymax    = this.ymax;
		var ymin    = this.ymin;
		var ydiff   = this.ymax - this.ymin;
		var xmax    = this.xmax;
		var xmin    = this.xmin;
		var xdiff   = this.xmax - this.xmin;
	
		jg.setStroke(1);
		jg.setColor("black");
		
		drawRect ( jg, 0, 0, this.width, this.height );
		var gt = padding;								//	graph top
		var gb = this.height - padding - bottom;	//	graph bottom
		var gl = padding + left;						//	graph left
		var gr = this.width - padding;				//	graph right
		var gw = gr - gl;									//	graph width
		var gh = gb - gt;									//	graph height

		jg.setFont("Arial", this.labelSize+"px",  Font.PLAIN);
		jg.setStroke(1);

		var i;
		var ygridlines = 4;
		for(i = 0 ; i <= ygridlines ; i++) {
			//	grid line color (from user?)
			jg.setColor("silver");
			//	draw Y-Axis grid lines
			jg.drawLine( gl, gt+Math.round((gh/ygridlines*i)), gr, gt+Math.round((gh/ygridlines*i)));
			//	 label color (from user?)
			jg.setColor("black");
			var label;
			if ( ydiff < 10 ) {
				label = Math.round( ( ymax - (ydiff / ygridlines * i)) * 10) / 10;
			} else {
				label = Math.round ( ymax - (ydiff / ygridlines * i));
			}
			// draw Y-Axis labels
			jg.drawStringRect ( label+"", padding, gt+i*(Math.round((gh/ygridlines)))-this.labelSize/2, left,"center");
		}

		var xgridlines = 5;
		for(i = 0 ; i <= xgridlines ; i++) {
			var label;
			if ( this.xIsDate ) {
				var date  = new Date();
				var xlabel = xmin + xdiff / xgridlines * i;
				date.setTime ( xlabel );
				year = date.getFullYear();
				month = date.getMonth() + 1;
				label = year+"/"+month;
			} else {
//				label = Math.round ( xmin + (xdiff / xgridlines * i));
				if ( xdiff < 10 ) {
					label = Math.round( ( xmin + (xdiff / xgridlines * i)) * 10) / 10;
				} else {
					label = Math.round ( xmin + (xdiff / xgridlines * i));
				}
			}
			// draw X-Axis labels
			jg.drawStringRect ( label+"", gl+i*Math.round(gw/xgridlines)-left, gb+this.labelSize, 2*left, "center");
		}

		jg.setColor("blue");
		drawRect ( jg, gl, gt, gr, gb );

		var oldx, oldy;
		jg.setStroke(1);

		if ( this.Lines ) {
			jg.setColor( this.lineColor );
			for(i = 0; i < this.ydata.length; i++) {
				var yval = Math.round ( gh * (ymax - this.ydata[i])/ydiff );		// number of pixels
				var xval = Math.round ( gw * (this.xdata[i]-xmin)/xdiff );		// number of pixels
				if(i >= 1)
					jg.drawLine(gl+oldx, gt+oldy, gl+xval, gt+yval);
				oldx = xval;
				oldy = yval;
			}
		}

		// Draw markers
		if ( this.Marks ) {
			jg.setColor ( this.markColor );
			for(i = 0; i < this.ydata.length; i++) {
				var yval = Math.round ( gh * (ymax-this.ydata[i])/ydiff );		// number of pixels
				var xval = Math.round ( gw * (this.xdata[i]-xmin)/xdiff );		// number of pixels
				// draw the points ( the -2's are to center the dots (half the diameter) )
				jg.fillEllipse ( gl+xval-2, gt+yval-2, 5, 5 );	
			}
		}

		jg.setColor ( this.titleColor );
		jg.setFont ( "Arial", this.titleSize+"px",  Font.BOLD );
		jg.drawStringRect ( title, gl, this.height - this.titleSize - this.padding/2, gw, "center");
		jg.paint();
	}
}
