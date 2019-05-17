import qh from "convex-hull";
import sample from './sample';
import './OrbitControls';

const $={};
["upload","help","canvas","file","uploadMenu","loadTest","loadRef"].forEach(s=>{
  $[s]=document.getElementById(s);
  $[s].on = $[s].addEventListener;
});


let test=getData(sample), ref=getData(sample), scene;

const camera = makeCamera();
const canvas = $.canvas;
const controls = new THREE.OrbitControls( camera , canvas);
const renderer = new THREE.WebGLRenderer({canvas});
renderer.setSize( window.innerWidth, window.innerHeight );
updateScene();
const animate = function () {
  requestAnimationFrame( animate );
  controls.update();
  renderer.render( scene, camera );
};

let uploadMenu = false;
$.upload.on('click',()=>{
  if (uploadMenu){
    $.uploadMenu.classList.add('hidden');
  } else {
    $.uploadMenu.classList.remove('hidden');
  }
  uploadMenu = !uploadMenu;
});
$.canvas.on('click',()=>{
  if (uploadMenu){
    $.uploadMenu.classList.add('hidden');
    uploadMenu = false;
  }
});
$.loadTest.on('click',()=>{
  $.file.onchange = ()=>{
    const reader = new FileReader();
    reader.onload = ()=>{
      test = getData(reader.result);
      updateScene();
    };
    reader.readAsText($.file.files[0]);
  };
  $.file.click();
});

$.loadRef.on('click',()=>{
  $.file.onchange = ()=>{
    const reader = new FileReader();
    reader.onload = ()=>{
      ref = getData(reader.result);
      updateScene();
    };
    reader.readAsText($.file.files[0]);
  };
  $.file.click();
});

window.addEventListener( 'resize', onWindowResize, false );

function onWindowResize(){

  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();

  renderer.setSize( window.innerWidth, window.innerHeight );

}

animate();

function updateScene(){
  const mesh = makeCIELabMesh(test);
  const wire = makeWireFrame(makeCIELabMesh(ref));
  scene = new THREE.Scene();
  scene.add(mesh);
  scene.add(wire);
}


function getData(s) {
  const validData = /^\s*\d+(\s+\d+){3}(\s+\d*.?\d+){3}\s*$/;
  const array = s
    .split('\n')
    .filter(l => validData.test(l))
    .map(l => l
      .split(/\s+/)
      .map(Number.parseFloat)
    );
  const rgb = array.map(a => a.slice(1, 4));
  const cols = rgb.map(c => (c[0] << 16) + (c[1] << 8) + c[2]);
  const xyz = array.map(a => a.slice(4));
  return {array, rgb, cols, xyz, count:array.length};
}

function sumArrays(d){
  return d.reduce((a,b)=>a?a.map((v,i)=>v+b[i]):b);
}

function offsetArrays(d,o){
  return d.map(a=>a.map((v,i)=>v+o[i]));
}

function mag(a){
  return Math.sqrt(a.reduce((t,v)=>t+v*v,0));
}

function unitVector(a){
  const d=mag(a);
  return a.map(v=>v/d);
}

function maxArray(a,fn){
  return a.reduce((m,dat)=>{
    const r={val:fn(dat),dat};
    return m && m.val>=r.val ? m : r;
  },null).dat;
}

function normArrays(d,n){
  return d.map(a=>a.map((v,i)=>v/n[i]));
}

function makeCIELabMesh(s){
  const {rgb, cols, xyz, count} = s;
  const offset = sumArrays(rgb).map(v=>-v/count);
  const points = offsetArrays(rgb,offset).map(p=>unitVector(p));
  const faces = qh(points);

  const max = maxArray(xyz,a=>a[1]);
  const bla = normArrays(xyz,max).map(xyz2lab).map(p=>[p[2],p[0],p[1],]);

  const geometry = new THREE.Geometry();
  for (let i = 0; i < points.length; i += 1) {
    geometry.vertices.push(new THREE.Vector3().fromArray(bla[i]));
    //geometry.vertexColors.push(new THREE.Color(cols[i]));
  }
  let normal;
  for (let i = 0; i < faces.length; i += 1) {
    const a = new THREE.Vector3().fromArray(bla[faces[i][0]]);
    const b = new THREE.Vector3().fromArray(bla[faces[i][1]]);
    const c = new THREE.Vector3().fromArray(bla[faces[i][2]]);
    normal  = new THREE.Vector3()
      .crossVectors(
        new THREE.Vector3().subVectors(b, a),
        new THREE.Vector3().subVectors(c, a)
      )
      .normalize();
    geometry.faces.push(
      new THREE.Face3(faces[i][0], faces[i][1], faces[i][2], normal, [new THREE.Color(cols[faces[i][0]]),new THREE.Color(cols[faces[i][1]]),new THREE.Color(cols[faces[i][2]])])
    );
  }

  return new THREE.Mesh(
    geometry,
    new THREE.MeshBasicMaterial( { vertexColors:THREE.VertexColors })
  );
}

function makeWireFrame(mesh){
  const helper                = new THREE.WireframeHelper(mesh);
  helper.material.depthTest   = false;
  helper.material.opacity     = 0.25;
  helper.material.transparent = true;
  return helper;
}

function makeCamera(){
  let camera,
    width = window.innerWidth,
    height = window.innerHeight,
    fov, ratio, near, far;

  // origin camera
  fov = 22.5;
  ratio = width / height;
  near = 1;
  far = 1000;
  camera = new THREE.OrthographicCamera(
    -width / 4, width / 4, height / 4, height / -4, near, far
  );
  camera.position.set(200, 300, 200);
  camera.lookAt(new THREE.Vector3(0, 50, 0));
  return camera;
}



function labF(v) {
  return v <= 0.008856 ? v * 7.787 + 16 / 116 : Math.pow(v, 1 / 3);
}
function xyz2lab(a){
  const fy=labF(a[1]);
  return [116*fy-16, 500*(labF(a[0])-fy), 200*(fy-labF(a[2]))];
}


