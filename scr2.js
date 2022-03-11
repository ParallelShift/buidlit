const rigabi = []

import connect from './Connect.js';
import * as THREE from "https://cdn.skypack.dev/three@0.136.0";
import { OrbitControls } from "https://cdn.skypack.dev/three@0.136.0/examples/jsm/controls/OrbitControls";
import { GLTFLoader } from 'https://cdn.skypack.dev/three@0.136.0/examples/jsm/loaders/GLTFLoader.js';

function test(){};

const container = document.getElementById('box_button2');

let ratio = 800/600;
var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera(55, ratio, .1, 1000);
// camera.lookAt(scene.position);

var clock = new THREE.Clock();

var renderer = new THREE.WebGLRenderer();
renderer.setPixelRatio(window.devicePixelRatio);
renderer.setSize(800, 600);
container.appendChild(renderer.domElement);
// Floor
let floorGeometry = new THREE.PlaneGeometry(10, 10, 1, 1);
let floorMaterial = new THREE.MeshPhongMaterial({ color: 0x111111 });
let floor = new THREE.Mesh(floorGeometry, floorMaterial);
floorMaterial.map = THREE.ImageUtils.loadTexture('./img/ground.jpg');

floor.rotation.x = -0.5 * Math.PI; // This is 90 degrees by the way
floor.receiveShadow = true;
floor.position.y = -1.5;
scene.add(floor);
// 
camera.position.y = 2.8;
camera.position.x = 0;
camera.position.z = 10;


const bgloader = new THREE.TextureLoader();
const bgTexture = bgloader.load('./img/water.jpg' );
//////////////////////////////////.////////////////////////
scene.background = bgTexture;
let controls = new OrbitControls(camera, renderer.domElement);
controls.enablePan = false;
// controls.minDistance = 5;
// controls.maxDistance = 10 ;
controls.enableDamping = true;
controls.autoRotate = false;

var charGltf0, charGltf, charGltf1, mixer, foxmixer, action, action1, action2;

const loader = new GLTFLoader();
const loader0 = new GLTFLoader();
const loader1 = new GLTFLoader();
const loader2 = new GLTFLoader();
var model1 = "sphere-bots1.glb";
var model2 = "./models/headm4-capo.glb";

function loadmodel(m){
    loader0.load(m, function (character) {
    charGltf = character.scene,
        charGltf.position.y = - 1.5;
        scene.add(charGltf)
    mixer = new THREE.AnimationMixer(charGltf);
    character.animations.forEach((clip) => {
    mixer.clipAction(clip).play();
    });

}, undefined, function (error) {

    console.error(error);

});
}
buy();
function buy(){
    loadmodel(model2);
    connect.then((result) => {})
    if (typeof window.ethereum == "undefined") {
	rej("install metamask!");

}
window.ethereum.request({ method: "eth_requestAccounts" });
// console.log(accounts[0]);
// let eb3 = new Web3(window.ethereum);
        // let contract = new eb3.eth.Contract(rigabi, "0x213792476B0dfBb4c91991340F2BC322828f0E5D");
        // contract.methods
        // .totalSupply()
        // .call({ from: "0xD12BF4c31b4aE8de5a89D0cDD05a1a5014560569" })
        // .then((result) => {
        // contract.methods.BuyRig(0)
        // .call({ from: "0xD12BF4c31b4aE8de5a89D0cDD05a1a5014560569" });
        //  console.log( result )
        // })
    }

document.addEventListener("keydown", onDocumentKeyDown, false);
function onDocumentKeyDown(event) {
    var keyCode = event.which;
    if (keyCode == 83) {
        charGltf.position.z = charGltf.position.z - .1;
        renderer.render(scene, camera);
        if (charGltf) charGltf.rotation.z + 1;
        action1.play();
    } else if (keyCode == 87) {
        charGltf.position.z = charGltf.position.z + .1;
        renderer.render(scene, camera);
        action1.play();
    } else if (keyCode == 65) {
        charGltf.position.x = charGltf.position.x - .1;
        renderer.render(scene, camera);
        action1.play();

    } else if (keyCode == 68) {
        charGltf.position.x = charGltf.position.x + .1;
        renderer.render(scene, camera);
        action1.play();

    } else if (keyCode == 32) {
        // action2.play();
    }
};

document.addEventListener("keyup", onDocumentKeyUp, false);

function onDocumentKeyUp(event) {
    var keyCode = event.which;
};

const light = new THREE.AmbientLight(0xffffff); // soft white light
scene.add(light);
light.intensity = 2.5;

var light1 = new THREE.HemisphereLight(0xff5555, 0xffffff, 3.5);
scene.add(light1);

var animate = function () {
    requestAnimationFrame(animate);
    var delta = clock.getDelta();
    if (mixer) mixer.update(delta);

    renderer.render(scene, camera);
};

animate();

