var requestAnimationFrame = window.requestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.msRequestAnimationFrame ||
        function (callback) { setTimeout (callback, 1000 / 30); };

var canvas = document.getElementById("canvas-id");
canvas.width = 1000;
canvas.height = 500;
var context = canvas.getContext("2d");
context.strokeStyle = "black";

const kC = 8987551787;
const G = 0.0000000000667;

var object = [];

var env = {};
env.sizeX = 10000;
env.sizeY = 10000;
env.offset = {x: 0, y: 0};
env.zoom = 1;

reset();

function Object(x, y, dx, dy, e, m)
{
    this.x = x;
    this.y = y;
    this.dx = 0;
    this.dy = 0;
    this.E = e;
    this.mass = m;
    this.size = Math.sqrt(this.mass) / 30000;
}

function reset()
{
	object.length = 0;
	for(var a = 0;a < 1200;a ++)
	{
        var E = Math.floor((Math.random() * 2 - 1) * 10) / 10;
        var m = Math.floor((Math.random() * 1000000000) * 10) / 10;
		object[a] = new Object(Math.random() * canvas.width, Math.random() * canvas.height, 0, 0, E, m);
	}
}

function drawArc(x,y,size,type)
{
    context.beginPath();
    context.arc(x,y,size,0.1, Math.PI * 2 + 0.1);
    context.closePath();
    if(type == "fill"){context.fill();}else{context.stroke();}
}

function distanceBetween(x1,y1,x2,y2)
{
    var alpha = x1 - x2;
    var beta = y1 - y2;
    return Math.sqrt((alpha*alpha)+(beta*beta));
}

window.addEventListener("mousewheel", function (args)
{
    if(args.wheelDelta < 120)//nagore
    {
        env.zoom += 0.1;
    }
    else
    {
        env.zoom -= 0.1;
        if(env.zoom <= 0.1)
        {
            env.zoom = 0.1;
        }
    }
}, false);

Array.prototype.remove = function(from, to)
{
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

function update()
{
    var E, mass, tx, ty;
	for(var a = 0;a < object.length;a ++)
	{  
        for(var j = 0;j < object.length;j ++)
        {
            if(a != j && object[a] != undefined && object[j] != undefined)
            {
                tx = object[j].x;
                ty = object[j].y;
                E = object[j].E;
                mass = object[j].mass;
                var dist = distanceBetween(object[a].x, object[a].y, tx, ty) / 1;
                object[a].dx += ((tx - object[a].x) / dist) * ( -(kC * E * object[a].E / (dist * dist)) / object[a].mass) / 1;
                object[a].dy += ((ty - object[a].y) / dist) * ( -(kC * E * object[a].E / (dist * dist)) / object[a].mass) / 1;
                object[a].dx += ((tx - object[a].x) / dist) * (G * mass * object[a].mass / (dist * dist) / object[a].mass) / 1;
                object[a].dy += ((ty - object[a].y) / dist) * (G * mass * object[a].mass / (dist * dist) / object[a].mass) / 1;
                if(dist / 9 * 10 < object[a].size + object[j].size)
                {
                    var bx = object[j].x, by = object[j].y;
                    if(object[a].mass > object[j].mass)
                    {
                        bx = object[a].x;
                        by = object[a].y;
                    }
                    object[a].dx *= object[a].mass;
                    object[a].dy *= object[a].mass;
                    object[a].dx += object[j].dx * object[j].mass;
                    object[a].dy += object[j].dy * object[j].mass;
                    object[a].E += object[j].E;
                    object[a].mass += object[j].mass;
                    object[a].dx /= object[a].mass;
                    object[a].dy /= object[a].mass;
                    object[a].x = bx;
                    object[a].y = by;
                    object[a].size = Math.sqrt(object[a].mass) / 30000;
                    object.remove(j);
                    j --;
                }
            }
        }
        if(object[a] != undefined)
        {    
            object[a].x += object[a].dx;
            object[a].y += object[a].dy;   
        }
	}
    setTimeout(update, 20);
}

var pressedKey = [];
for(var a = 0;a < 100;a ++)
{
    pressedKey[a] = false;
}
document.addEventListener('keydown', checkKeyDown, false);
document.addEventListener('keyup', checkKeyUp, false);

function checkKeyDown(e)
{
    var keyID = e.keyCode || e.which;
    pressedKey[keyID] = true;
    e.preventDefault();
}

function checkKeyUp(e)
{
    var keyID = e.keyCode || e.which;
    pressedKey[keyID] = false;
    e.preventDefault();
}

function moveOffset()
{
    if(pressedKey[65])
    {
        env.offset.x += 5 * env.zoom;
    }
    if(pressedKey[87])
    {
        env.offset.y += 5 * env.zoom;
    }
    if(pressedKey[68])
    {
        env.offset.x -= 5 * env.zoom;
    }
    if(pressedKey[83])
    {
        env.offset.y -= 5 * env.zoom;
    }
    setTimeout(moveOffset, 5);
}

function draw()
{    
    context.clearRect(0, 0, canvas.width, canvas.height);
    
    for(var a = 0;a < object.length;a ++)
    {
        if(object[a].E > 0){context.fillStyle = "red";}
        if(object[a].E < 0){context.fillStyle = "blue";}
        if(object[a].E == 0){context.fillStyle = "black";}
    	drawArc((object[a].x + env.offset.x) / env.zoom, (object[a].y + env.offset.y) / env.zoom, object[a].size / env.zoom, "fill");
    }
    context.strokeRect(0, 0, canvas.width, canvas.height);
    requestAnimationFrame(draw);
}
moveOffset();
update();
draw();

