{
  // See imports from zconfig.json
  // imports transform from ziffers.ts
  // imports DEFAULT_DURS from defaults.ts

  var nodeOptions = options.nodeOptions || {};

  function build(ClassReference, values) {
    values.text = text();
    values.location = location();
    // Merge all default options to values if value is not set, null or undefined
    for (var key in nodeOptions) {
      if (values[key] === undefined || values[key] === null) {
        values[key] = nodeOptions[key];
      }
    }
    return new ClassReference(values);
  }
  
  // console.log("OPTIONS:", options);
  
}

start = s:statement 
{ 
  return s.filter(a => a);
}

// ----- Numbers -----

float = ("-"? [0-9]* "." [0-9]+ / "." [0-9]+) 
{ return parseFloat(text()) }

int = "-"? [0-9]
{ return parseInt(text()); }

// ------------------ delimiters ---------------------------

ws "whitespace" = [ \n\r\t] 
{ return undefined }

comma = ws "," ws
pipe = ws "|" ws
quote = '"' / "'"


durchar = [a-z] 
{ return DEFAULT_DURS[text()]; }

duration = durchar / float

statement = items

items = n:(repeat / list_operation / list / item / cycle)+
{ return n.filter(a => a) }

list = "(" l:(items) ")"
{ return build(types.List,{items: l}) }

list_operation = a:list b:operation c:list
{ return build(types.ListOperation,{left: a, operation: b, right: c});  }

operation = "+" / "-" / "*" / "/" / "%" / "^" / "|" / "&" / ">>" / "<<"

item = v:(chord / pitch / octave_change / ws / duration_change / random / random_between / list)
{ return v }

cycle = "<" l:items ">" 
{ return build(types.Cycle,{items: l}) }

octave_change = octave:octave
{ 
  options.nodeOptions.octave = octave;
  return build(types.OctaveChange,{octave: octave}); 
}

octave = ("^" / "_")+
{ 
  return text().split('').reduce((sum, char) => sum + (char === '^' ? 1 : -1), 0);
}

random = "?"
{ return build(types.RandomPitch,{}) }

random_between = "(" a:int "," b:int ")"
{ return build(types.RandomPitch,{min: a, max: b }) }

repeat = n:item ":" i:int
{ return build(types.Repeat,{item: n, times: i}) }

duration_change = dur:duration 
{ 
  options.nodeOptions.duration = dur;
  return build(types.DurationChange,{duration: dur}) 
}

pitch = oct:octave? dur:duration? val:int 
{ 
  const octave = oct ? options.nodeOptions.octave+oct : options.nodeOptions.octave
  return build(types.Pitch, {duration: dur, pitch: val, octave: octave})
}

chord = left:pitch right:pitch+
{ return build(types.Chord, {pitches:[left].concat(right)}) }

