const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const html = readFileSync(join(__dirname, '../Web/WalletSkinLab.html'), 'utf8');
const script = html.split('<script>')[1].split('</script>')[0];
new vm.Script(script);
const draw = script.slice(script.indexOf('function drawCover'), script.indexOf('function frame'));
let rect;
const context = { W:1536, H:969, ctx:{drawImage: (_, ...args) => { rect = args; }} };
vm.runInNewContext(draw, context);
for (const [w,h] of [[100,200],[300,100],[1536,969]]) {
  for (const zoom of [100,250]) {
    for (const offset of [-700,0,700]) {
      context.drawCover({width:w,height:h}, 'cover', zoom, offset, offset);
      const [x,y,width,height] = rect;
      assert(x <= 0 && y <= 0 && x + width >= 1536 && y + height >= 969);
      assert(Math.abs(width/height-w/h) < 1e-8);
    }
  }
  context.drawCover({width:w,height:h}, 'contain',100,0,0);
  assert(rect[0]>=0 && rect[1]>=0 && rect[2]<=1536 && rect[3]<=969);
}
console.log('21 image placement cases passed');
