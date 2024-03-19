pragma circom 2.0.1;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template ArgMax (n) {
    signal input in[n];
    signal output out;
    component gts[n];        // store comparators
    component switchers[n+1];  // switcher for comparing maxs
    component aswitchers[n+1]; // switcher for arg max

    signal maxs[n+1];
    signal amaxs[n+1];

    maxs[0] <== in[0];
    amaxs[0] <== 0;
    for(var i = 0; i < n; i++) {
        gts[i] = GreaterThan(30);
        switchers[i+1] = Switcher();
        aswitchers[i+1] = Switcher();

        gts[i].in[1] <== maxs[i];
        gts[i].in[0] <== in[i];

        switchers[i+1].sel <== gts[i].out;
        switchers[i+1].L <== maxs[i];
        switchers[i+1].R <== in[i];

        aswitchers[i+1].sel <== gts[i].out;
        aswitchers[i+1].L <== amaxs[i];
        aswitchers[i+1].R <== i;
        amaxs[i+1] <== aswitchers[i+1].outL;
        maxs[i+1] <== switchers[i+1].outL;
    }

    out <== amaxs[n];
}

// image is non-negative length 84 vector, output from prior NN layers running in the web frontend 
// A is final fully-connected layer's weights, 10x84 shape matrix (n=84)
// B is final bias, length 10 vector
template DigitReader (b, n) {
    signal input image[b][n]; // must be non-negative
    //signal output digit;
    signal output digits[b];
    var ndigits = 10;

    // copy the values of A and B from the snarklayer.tsx file
    var A2[ndigits][n] =
    [
[12,-124,-189,156,127,-10,-65,-82,0,175,-192,-186,130,99,51,-38,148,-333,70,-3,-158,-69,71,-89,88,-143,-55,190,26,34,220,-224,-107,-85,-67,-101,-82,-145,33,26,115,-20,80,-72,-151,106,38,-61,-46,128,-14,-36,78,-261,-148,168,134,77,33,267,230,-108,31,-183,-7,-76,17,-5,57,-177,132,34,33,155,62,204,-48,-198,-110,-5,130,-210,17,-79],
[93,-202,-154,-73,-257,134,-45,-11,196,81,40,-10,139,-27,-61,0,-41,209,-144,-2,129,-131,-75,-202,76,-21,9,-28,-9,-165,-224,155,-25,-29,95,144,-129,-171,-250,67,46,25,-285,-93,71,108,55,67,-98,-47,1,-53,244,131,-172,37,0,-249,-1,12,-21,256,87,204,-104,6,-41,-112,-16,173,-25,183,-47,-200,-189,23,-117,-5,90,-7,-18,223,59,-34],
[-38,17,-114,50,-258,-98,72,-37,-10,-152,45,51,-135,1,12,-111,33,-22,-75,210,-155,136,86,32,124,-48,-88,143,-100,33,110,6,-253,55,-149,-282,69,-164,189,-86,-73,-34,-65,-4,209,-55,170,-164,107,147,-155,-94,178,98,-107,154,-158,-150,139,-24,98,-40,47,-270,0,216,55,-57,17,34,-138,-4,-9,156,-185,20,69,-159,61,-2,148,87,-43,-91],
[-74,-70,-135,16,9,199,-103,-74,13,37,125,12,-251,29,24,-144,99,-184,-16,86,-60,-89,30,-130,-77,-91,-66,-100,-70,94,61,-210,131,200,-102,-228,51,235,-36,-21,-61,-114,-107,292,-138,19,-109,234,-105,-29,253,8,-187,185,161,68,-157,-77,76,-120,-50,-4,-22,18,18,-54,-25,-51,37,-59,89,-197,-93,-154,-175,27,-130,-26,-9,68,-68,163,-11,44],
[-4,139,169,-187,178,-143,-33,-38,95,-235,15,150,56,-67,92,-148,-44,-61,82,-38,68,-75,152,143,-4,-145,7,-56,-28,-235,90,125,3,-289,84,208,-28,-37,110,-38,-109,-139,127,-108,-57,-25,156,-151,-99,-160,-245,-30,22,-28,-2,-253,-116,109,-41,-25,4,40,-191,90,-240,-91,-116,-59,63,-180,-8,-101,110,89,-159,-97,-134,153,0,-97,171,-213,-167,-21],
[17,-198,-16,168,196,-247,27,72,41,36,23,-169,-102,-19,-145,-58,189,53,-42,41,131,-37,-359,-5,32,-14,-18,34,-139,116,144,-183,220,141,-89,84,83,113,-15,-88,-102,52,193,103,74,61,-69,159,-118,93,38,-86,-64,-286,4,-151,253,-3,0,-11,65,-182,69,65,78,4,160,25,-44,-143,-39,40,-80,-311,219,-30,-68,-37,25,-80,-68,0,51,65],
[82,-210,-114,-69,48,-144,9,36,-100,47,-80,-144,247,-44,-81,122,49,100,215,-144,-199,120,-174,-123,-113,-148,-94,164,-61,-78,-126,-79,29,128,62,198,-126,-208,130,55,9,-3,-2,-53,95,-37,132,-48,-186,33,131,131,-130,-262,-79,-86,209,166,26,-2,-68,-220,56,-79,-115,102,63,-82,-99,-49,-44,3,94,-174,-42,-35,73,-150,-106,-16,157,-210,-19,32],
[-48,199,264,-95,64,-25,102,31,-101,165,139,41,-89,-59,-65,74,-76,77,-174,55,-87,66,135,-66,-47,-152,177,-203,-135,137,71,54,-335,-319,-147,-96,79,84,102,-65,-93,108,150,4,-136,80,-201,10,155,162,-126,8,100,118,-195,105,106,-264,111,-147,15,2,45,-56,74,-247,-16,94,-117,156,157,-102,-63,-72,-16,87,-39,8,-31,80,-227,-42,86,3],
[-9,143,90,122,104,-109,-110,94,-176,-164,-222,-163,-88,34,67,114,-272,-101,39,-50,213,106,-100,197,56,28,-33,-120,33,-27,-250,-37,191,195,-107,-114,141,41,104,-105,141,95,-252,-16,16,-17,-24,119,31,-224,115,-145,32,19,-67,131,-135,173,87,-95,122,9,170,21,2,171,-164,111,-190,1,91,26,-26,124,27,-82,91,65,36,-66,-86,127,66,-106],
[56,0,162,133,57,-146,-17,-144,1,101,149,-32,-114,37,151,75,51,0,-92,-122,-9,-252,91,31,-49,-51,-206,75,82,128,-110,-32,126,-182,-267,159,-172,235,-172,-60,-141,59,64,-22,-31,-26,-255,-81,81,-72,-82,-54,-212,-91,-34,-246,-167,223,-120,29,-236,25,-150,99,68,-200,14,135,177,-25,-177,40,60,99,161,46,-112,221,85,13,-252,13,14,106]];

    var Bb[ndigits] = [ -57068,33988,72676,115488,-84896,-15568,-94943,-115469,103303,-90709];

    var A[ndigits][n] = [
[12,-76,-130,109,105,81,-190,-35,-121,152,-200,-212,126,101,-11,-42,120,-269,44,-95,-239,-122,83,-142,188,-313,-70,152,-44,25,100,-97,-28,-92,-63,-46,-69,-94,47,-29,25,49,76,-74,-124,105,54,-47,-26,33,-16,4,130,-151,-98,151,49,71,50,140,117,-123,0,-114,2,-106,51,46,68,-61,90,-1,33,91,41,134,-51,-106,-91,-17,98,-98,65,-184],
[92,-143,-67,-10,-73,119,-83,7,167,113,-37,-12,152,-28,-34,20,139,78,-66,42,53,-163,-74,-196,104,18,29,-56,-1,-193,-74,121,-47,-9,18,146,-137,-202,-225,67,50,81,-181,-64,100,29,24,137,4,53,11,-87,187,102,-193,-1,43,-192,12,72,-27,173,80,140,-174,22,-52,-162,-31,67,-37,134,-56,-129,-168,136,-94,51,82,74,-34,139,82,-13],
[-37,-15,-183,0,-160,-71,66,-35,40,-149,68,44,-131,1,31,-65,42,1,-82,158,-160,116,53,41,125,-170,-106,139,-83,14,86,-13,-128,41,-73,-194,127,-143,138,-88,-74,-33,-35,-33,135,-38,128,-111,117,144,-167,-43,147,60,-119,156,-172,-66,161,-49,78,0,22,-214,14,152,70,-154,-10,-38,-133,88,-8,146,-162,78,40,-165,56,-53,126,70,-67,-98],
[-72,-122,-95,31,-11,104,-163,-101,43,34,67,-71,-186,24,54,-225,122,-103,6,112,32,-141,43,-82,-179,-41,-60,-153,-39,51,-33,-157,125,129,-159,-183,37,153,-29,-22,-45,-161,-73,148,-74,28,-43,159,-112,-24,138,109,-140,104,125,12,-94,-9,182,-202,-18,-30,18,-69,-19,-45,-32,17,-37,-66,142,-324,-99,-116,-116,63,-100,-42,-4,108,-78,116,13,94],
[-5,106,131,-121,129,-187,-29,-39,143,-150,53,163,121,-68,32,-144,35,20,41,-122,76,-50,96,73,-157,-92,0,1,-32,-259,129,161,-72,-192,8,155,-43,-15,26,-4,-59,-187,114,-121,-42,-15,101,-96,-76,-168,-113,-31,105,-55,-51,-172,-11,37,-181,-12,44,35,-240,151,-291,-76,-106,-12,1,-30,30,-93,106,-18,-126,-187,-59,134,-8,-217,100,-167,-113,32],
[17,-109,-18,162,106,-162,26,67,-10,-15,-40,-79,-129,-28,-139,-101,111,-120,-88,76,132,8,-268,34,-41,44,-56,-1,-60,108,97,-206,156,102,-156,30,43,113,-43,-51,-12,115,137,110,16,64,-51,69,-86,58,15,-104,-102,-187,-46,-153,186,-28,-56,46,73,-185,167,57,60,0,56,27,32,-52,-101,33,-53,-153,173,-30,-21,-35,27,-132,-78,-4,13,56],
[82,-239,-175,-26,48,-181,-95,8,-126,81,-141,-158,178,-42,-103,147,59,69,146,-165,-211,142,-127,-103,-105,-154,-58,132,-79,-92,-95,-117,27,119,97,130,-145,-209,167,21,-10,81,1,85,69,5,123,-37,-290,-39,116,46,-76,-201,-21,1,202,111,-75,-50,-35,-154,15,-54,-103,89,24,-196,-72,-5,-102,72,99,-150,-30,-152,-7,-166,-102,-103,134,-137,-12,-62],
[-48,123,154,-156,54,-107,189,-22,-123,141,92,15,25,-48,-73,24,-135,107,-272,159,-12,93,82,-85,-8,-163,25,-190,-88,99,65,49,-268,-217,-186,-49,96,43,-26,-81,-33,40,106,-124,-157,84,-198,44,125,102,-71,27,94,68,-171,79,264,-184,121,-15,15,-84,47,-107,37,-152,-45,129,-21,57,77,-163,-42,-85,-10,137,-8,-13,-5,114,-280,-68,31,96],
[-9,150,103,90,70,-55,-155,41,-163,-156,-145,-119,-109,35,105,139,-249,-161,71,-4,93,110,10,110,111,20,-73,-204,15,-17,-158,-57,104,116,-14,-91,154,104,116,-92,58,106,-177,64,15,7,-75,117,18,-220,82,-166,21,34,-18,66,-215,41,56,-118,118,-12,103,-2,-29,85,-91,138,-59,35,44,-7,43,69,-37,-174,50,49,45,-107,-113,72,37,-231],
[55,-22,147,126,0,-102,9,-58,21,84,181,-52,-132,36,113,102,48,53,-13,-219,-31,-277,46,25,-157,-41,-53,169,50,187,-83,-58,103,-85,-167,102,-149,183,-85,-50,-98,-10,3,-4,12,-34,-171,-124,88,64,-102,-43,-159,-88,-54,-193,-273,163,-70,22,-235,90,-76,87,51,-31,40,93,117,-35,-24,-14,12,96,129,22,-85,170,25,21,-51,62,-22,92]];
    var B[ndigits] =  [
      -44638,
      -28147,
      100997,
      78663,
      -88454,
      6349,
      -97006,
      -126437,
      52297,
      -88181];
    signal s[b][ndigits][n+1];
    //component am = ArgMax(ndigits);
    component ams[b];
    for(var idx=0; idx < b; idx++) {
        ams[idx] = ArgMax(ndigits);
        for(var i=0; i<ndigits; i++){
            s[idx][i][0] <== 0;
            for(var j=1; j<=n; j++){
                s[idx][i][j] <== s[idx][i][j-1] + A[i][j-1]*image[idx][j-1];
            }
            //am.in[i] <== s[idx][i][n]+B[i] + 10000000;
            ams[idx].in[i] <== s[idx][i][n]+B[i] + 1000000000;
            //log(am.in[i]);
            //log(ams[idx].in[i]);
            if (idx == 0) {
              log(i);
              log(s[idx][i][n] + B[i] + 1000000000);
              log(999999);
            }
        }
      ams[idx].out ==> digits[idx];
      if (idx == 0) {
          log(ams[idx].out);
          log(555555);
      }
    }
    //am.out ==> digit;
    //am.out ==> digit;
}

component main = DigitReader(16, 84);

/* INPUT = {
         "image": [34, 7, 3, 56, 34, 2, 11, 34, 7, 3, 56, 34, 2, 11, 34, 7, 3, 56, 34, 2, 11, 34, 7, 3, 56, 34, 2, 11, 34, 7, 3, 56, 34, 2, 11, 34, 7, 3, 56, 34, 2, 11, 34, 7, 3, 56, 34, 2, 11, 34,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
    0,0,0,0 ]
} */