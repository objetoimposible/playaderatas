// la funcion textToPoints es una funcion que devuelve una serie de puntos que representan un texto escrito dentro de la clase font. Tiene 5 argumentos: 1. str: cadena de texto 2. x: (abajo/izquierda) coordenada horizontal 3. y: (abajo/izquierda) coordenada vertical 4. fontSize 5. {sampleFactor, simplifyThreshold}: factor de muestra, umbral simplificado
let font; // variable para la tipo
let points = []; // array para los puntos
let palabras = []; // array palabras que cambian en bajada
var cnv;
function centerCanvas() {
  var x = (windowWidth - width) / 2;
  var y = (windowHeight - height) / 2;
  cnv.position(x, y);
}
//let texto1 = "repositorio de artes, técnicas y modos de escritura y registro del pensar/sentir/decir/hacer" 
//"(pensamos que pudiése ser buena idea pararse, alejarse de la pantalla unos metros y mirar, ¿que se ve?)"
function preload() {
  font = loadFont("../fonts/DXRigraf-SemiBold.otf"); // no puede ser cualquiera, no todas las tipos otf funcionan
  img1 = loadImage("../img/ratita_1.png")
}
function setup() {
  noLoop();
  frameRate(1);
  cnv = createCanvas(1000,400);
  cnv.parent('sketch-holder');
  centerCanvas();
}
function draw() {
  noStroke();
  fill(200);
  colorMode(HSB,255,255,255);
  background(230,24,217, 0);
  fill(255);
  ellipse(507,62,120,120);
  image(img1,width/2-(600/4)/2,-10,600/4,464/4);
  // obtener el array de puntos. pudiese ser animado con un perlin esta vez solo se utilizaron 4 de los argumentos de textToPoints
    let points = font.textToPoints("PLAYA de RATAS", -100, height / 1.5, 120, {sampleFactor: 0.15}); 
  // imprimir puntos variando el color dependiendo de su valor argumento alpha
  for (let p of points) {
  // condicionales color sobre umbral parametro alpha
    if (p.alpha < 50) {
      fill(random(255),random(155,200),random(255),random(255));
    } else {
      fill(random(255),random(155,205),random(255),random(255));
    }
    let randomSize = random(2, 20);
    ellipse(p.x+windowWidth/10, p.y, randomSize, randomSize);
  }
  noStroke();
  fill(120);
  // la funcion textBounds permite acceder al cuadro delimitador del texto, sus argumentos son iguales a los 4 primeros de textToPoints
  //let box = font.textBounds("R", 20, height / 2, 110);
  // impresion de rectangulo con valores de argumentos en la variable box
  //rect(box.x, box.y, box.w, box.h);
  textSize(16);
  textFont(font);
  fill(0,0,0);
  //text(texto1,225,370);
  }
  function windowResized() {
    centerCanvas();
}

