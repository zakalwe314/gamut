// quickhull3d
//
// A robust quickhull implementation to find the convex hull of a set of 3d points in O(n log n)
//
// github: https://github.com/mauriciopoppe/quickhull3d
// license: MIT
import qh from "convex-hull";
import t3 from "t3-boilerplate";
import sample from './sample';

t3.run({
  selector: "#canvas",
  helpersConfig: {
    ground: false,
    gridX: false,
    gridY: false,
    gridZ: false,
    axes: false
  },
  init: function() {

    const validData=/^\s*\d+(\s+\d+){3}(\s+\d*.?\d+){3}\s*$/;
    const data=sample.split('\n').filter(l=>validData.test(l)).map(l=>l.split(/\s+/).map(Number.parseFloat));
    const rgb = data.map(a=>a.slice(1,4));
    const cols = rgb.map(c=>(c[0]<<16)+(c[1]<<8)+c[2]);
    const xyz = data.map(a=>a.slice(4));
    const cent = rgb.reduce((a,b)=>[a[0]+b[0], a[1]+b[1], a[2]+b[2]],[0,0,0]).map(v=>v/data.length);
    const points = rgb.map(p=>[p[0]-cent[0],p[1]-cent[1],p[2]-cent[2]]).map(p=>{
      const d=Math.sqrt(p[0]*p[0]+p[1]*p[1]+p[2]*p[2])/100;
      return [p[0]/d,p[1]/d,p[2]/d];
    });
    const faces = qh(points);

    const max = xyz.reduce((a,b)=>a[0]+a[1]+a[2]>b[0]+b[1]+b[2]?a:b,[0,0,0]);
    const bla = xyz.map(a=>[a[0]/max[0],a[1]/max[1],a[2]/max[2]]).map(xyz2lab).map(p=>[p[2],p[0],p[1],]);

    const geometry = new THREE.Geometry();
    for (let i = 0; i < points.length; i += 1) {
      geometry.vertices.push(new THREE.Vector3().fromArray(bla[i]));
      //geometry.vertexColors.push(new THREE.Color(cols[i]));
    }
    let normal;
    for (let i = 0; i < faces.length; i += 1) {
      const a   = new THREE.Vector3().fromArray(bla[faces[i][0]]);
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

    const polyhedra = new THREE.Mesh(
      geometry,
      new THREE.MeshBasicMaterial( { vertexColors:THREE.VertexColors })
      );
    this.activeScene.add(polyhedra);

    const helper                = new THREE.WireframeHelper(polyhedra);
    helper.material.depthTest   = false;
    helper.material.opacity     = 0.25;
    helper.material.transparent = true;
    this.activeScene.add(helper);

    let camera,
        width = window.innerWidth,
        height = window.innerHeight,
        fov, ratio, near, far;

    // origin camera
    fov = 22.5;
    ratio = width / height;
    near = 10;
    far = 500;
    camera = new THREE.OrthographicCamera(
      -width / 4, width / 4, height / 4, height / -4, near, far
    );
    camera.position.set(100, 150, 100);
    camera.lookAt(new THREE.Vector3(0, 50, 0));
    this
      .addCamera(camera, 'orthographic')
      // add orbit controls to the camera
      .createCameraControls(camera)
      .setActiveCamera('orthographic');

    //this.activeScene.add(new THREE.FaceNormalsHelper(polyhedra, 10));
  },
  update: function(delta) {}
});


function labf(v) {
  return v <= 0.008856 ? v * 7.787 + 16 / 116 : Math.pow(v, 1 / 3);
}
function xyz2lab(a){
  const fy=labf(a[1]);
  return [116*fy-16, 500*(labf(a[0])-fy), 200*(fy-labf(a[2]))];
}
!function listeners(){
  const $={};
  let uploadMenu = false;
  ["upload","help","canvas"].forEach(s=>{
    $[s]=document.getElementById(s);
    $[s+'Menu']=$[s].querySelector('.menu');
  });
  $.upload.addEventListener('click',()=>{
    if (uploadMenu){
      $.uploadMenu.classList.add('hidden');
    } else {
      $.uploadMenu.classList.remove('hidden');
    }
    uploadMenu = !uploadMenu;
  });
  $.canvas.addEventListener('click',()=>{
    if (uploadMenu){
      $.uploadMenu.classList.add('hidden');
      uploadMenu = false;
    }
  })
}();
//   fX = ratio.^(1/3);
//   idx = find(ratio <= 0.008856);
//   fX(idx) = ratio(idx).*7.787 + (16/116);
//
// %calculate L*,a*,b*
//
//   Lab(1,:) = 116*fX(2,:)-16;
//   Lab(2,:) = 500*(fX(1,:)-fX(2,:));
//   Lab(3,:) = 200*(fX(2,:)-fX(3,:));


