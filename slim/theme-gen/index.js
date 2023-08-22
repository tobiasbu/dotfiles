var DEBUG_PANEL_HEIGHT = 24;

var utils = {
  getAbsoluteElCoords: function (elem) { // crossbrowser version
      var box = elem.getBoundingClientRect();

      var body = document.body;
      var docEl = document.documentElement;

      var scrollTop = window.pageYOffset || docEl.scrollTop || body.scrollTop;
      var scrollLeft = window.pageXOffset || docEl.scrollLeft || body.scrollLeft;

      var clientTop = docEl.clientTop || body.clientTop || 0;
      var clientLeft = docEl.clientLeft || body.clientLeft || 0;

      var top  = box.top +  scrollTop - clientTop;
      var left = box.left + scrollLeft - clientLeft;

      return { 
        absX: Math.round(top), 
        absY: Math.round(left), 
        width: box.width, 
        height: box.height,
        top: Math.ceil(box.top),
        left: Math.ceil(box.left),
        right: Math.ceil(box.right),
        bottom: Math.ceil(box.bottom),
        x:  Math.ceil(box.x),
        y:  Math.ceil(box.y),
      };
  },
  createDot: function (parent, coords) {
    var dot = document.createElement('div');
    dot.id = 'debug-pos';
    dot.style.position = 'absolute';
    dot.style.left = coords.left + 'px';
    dot.style.top = coords.top + 'px';
    dot.style.width = '2px';
    dot.style.height = '2px';
    dot.style.background = '#00ff00';
    parent.appendChild(dot);
  },
  getCoords: function() {
    var display = document.getElementsByClassName('display')[0];
    
    var user = document.getElementById("user-input");
    var pass = document.getElementById("pass-input");
    var userCoords = getElCoords(user);
    var passCoords = getElCoords(pass);

    console.log("user_input", userCoords);
    console.log("pass_input", passCoords);
    
    createDot(display, userCoords);
    createDot(display, passCoords);

  },
  getEl: function(name) {
    var el;
    switch(name.charAt(0)) {
        case ".":
          el = document.getElementsByClassName(name.substring(1))[0];
        break;
        
        case "#":
           el = document.getElementById(name.substring(1));
        break;
        
        default:
          el = document.getElementsByTagName(name)[0];
        break;  
    }
    
    if (!el) {
      return null;
    }
    return el;
  },
  getStyle: function(element) {
    var el = typeof element === "object" ? element : this.getEl(element);
    return el ? window.getComputedStyle(el, null) : false;
  },
  cssRgbToHex: function(rgbColor) {
    return rgbColor.match(/[0-9]+/g).reduce((a, b) => a+(b|256).toString(16).slice(1), '#')
  }
}

function createSlimThemeMk() {
  var str = "";
  var lastAddedField;
  var lastField;
  
  var mk = {
    line: function(text) {
      str += text + "\n";
      return mk;
    },
    newLine: function(text) {
      return mk.line("");
    },
    comment: function(text) {
      return mk.line("# " + text);
    },
    field: function(key, value) {
      var spacing = "        ";
      lastField = {
        key: key,
        value: value,
        spacing: spacing,
      }
      return mk.line(key + spacing + value);
    },
    getStr: function() {
      return str;
    }
  }
  return mk;
}


function processBackground(t, els) {
  var bgSt = utils.getStyle(els.bg);
  var bodySt = utils.getStyle(els.body);

  var bgColor = bgSt.backgroundColor ? bgSt.backgroundColor : bodySt.backgroundColor;
  if (!bgSt.backgroundColor) {
    bgColor = "rgb(0,0,0)";
  }
  
  t.comment("Background")
   .field("background_color", utils.cssRgbToHex(bgColor));
   
  var bgImg;
  if (bgSt.backgroundImage) {
    bgImg = bgSt.backgroundImage;
  } else {
    bgImg = bodySt.backgroundImage;
  }

  // stretch, tile, center
  if (bgImg && bgImg != "none") {
    //if (body.backgroundSize && !body.backgroundSize.includes(""))
  
    if (bgSt.backgroundRepeat && bgSt.backgroundRepeat != "no-repeat") {
      t.field("background_style", "tile")
    } else {
      t.field("background_style", "stretch")
    }
     
    
  } else {
    t.field("background_style", "solidcolor")
  }
}

function processPanel(t, els) {
   t.comment("Panel")
   var panelCoords = utils.getAbsoluteElCoords(els.panel);
   var userInputCoords = utils.getAbsoluteElCoords(els.userInput);
   var passInputCoords = utils.getAbsoluteElCoords(els.passInput);
   
   console.log(els.passInput)
   
   var panelSt = utils.getStyle(els.panel);
   var userSt = utils.getStyle(els.userInput);
   
   var h = Math.ceil((userInputCoords.bottom - userInputCoords.top) * 0.5 + 9 * 0.5);
   var ph = 0.5 * (passInputCoords.bottom - passInputCoords.top) - 9 * 0.5;
   
   console.log(passInputCoords);
   
   // TODO 
  t.field("input_panel_x", "50%")
   .field("input_panel_y","40%")
   .field("input_name_x", userInputCoords.left - panelCoords.left)
   .field("input_name_y", userInputCoords.absY - panelCoords.absY + h)
   .field("input_pass_x", passInputCoords.left - panelCoords.left)
   .field("input_pass_y", passInputCoords.bottom - panelCoords.top - ph);


  var welcomeSt = utils.getStyle(els.welcome);
  if (welcomeSt) {
    var welcomeCoords = utils.getAbsoluteElCoords(els.welcome);
    t.comment("Welcome");
    t.field("welcome_x", welcomeCoords.absX - panelCoords.absX)
     .field("welcome_y", welcomeCoords.absY - panelCoords.absY)
     .field("welcome_font", welcomeSt.fontFamily.split("\"")[1] +  ":" + welcomeSt.fontSize.split(".")[0])
     .field("welcome_color", utils.cssRgbToHex(welcomeSt.color));
  }
 
    //input_name_x            24
    //input_name_y            61
    //input_pass_x            24
    //input_pass_y            100
    //input_font              Sans:size=9
    //input_color           	#fff
}

function exportTheme() {
  var elements = {
    body: utils.getEl("body"),
    bg: utils.getEl("#background"),
    welcome: utils.getEl("#welcome"),
    panel: utils.getEl("#panel"),
    userInput: utils.getEl("#user-input"),
    passInput: utils.getEl("#pass-input"),
  };

  if (!elements.bg) {
    elements.bg = elements.body;
  }

  var t = createSlimThemeMk();
  
  t.comment("Theme for slim or SLIMski")
   .comment("Generated by slimker (created by @tobiasbu)\n");
  
  processBackground(t, elements);
  processPanel(t, elements);
  
  console.log(t.getStr());
  
  
}
