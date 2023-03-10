import { useEffect, useRef } from "react";
import * as THREE from "three";

// @ts-ignore-next-line
import vertex from "./shaders/vertex.glsl";
// @ts-ignore-next-line
import fragment from "./shaders/fragment.glsl";

export default function Header() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    if (!canvasRef.current) {
      return;
    }

    const scene = new THREE.Scene();
    const camera = new THREE.OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );

    const renderer = new THREE.WebGLRenderer({
      canvas: canvasRef.current,
      antialias: true,
    });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.pixelRatio = window.devicePixelRatio;

    window.addEventListener('resize', () => {
      renderer.setSize(window.innerWidth, window.innerHeight)
      // camera.aspect = window.innerWidth / window.innerHeight
      camera.updateProjectionMatrix()
    })

    const mouse = {
        x: 0,
        y: 0,
        prevX: 0,
        prevY: 0,
        vX: 0,
        vY: 0
    }

    const onMouseMove = (e: MouseEvent) => {
        mouse.prevX = mouse.x
        mouse.prevY = mouse.y
        mouse.x = e.clientX / window.innerWidth
        mouse.y = e.clientY / window.innerHeight
        mouse.vX = mouse.x - mouse.prevX
        mouse.vY = mouse.y - mouse.prevY
    }

    window.addEventListener('mousemove', onMouseMove)

    const sizeVal = 16;
    const maxDist = sizeVal / 16;
    const updateVal = 0.96;

    const width = sizeVal;
    const height = sizeVal;
    const size = width * height;

    // Create the datatexture
    const data = new Float32Array( 4 * size );
    for ( let i = 0; i < size; i ++ ) {
        const r = Math.random();
        const stride = i * 4;
        data[ stride ] = r;
        data[ stride + 1 ] = r;
        data[ stride + 2 ] = r;
        data[ stride + 3 ] = 255;
    }

    const dataTexture = new THREE.DataTexture( data, width, height, THREE.RGBAFormat, THREE.FloatType );
    dataTexture.magFilter = dataTexture.minFilter = THREE.NearestFilter;
    dataTexture.needsUpdate = true;

    function updateDataTexture() {
        const {data} = dataTexture.image;
        const size = data.length;
        for (let i = 0; i <= size; i += 4) {
            data[i] *= updateVal;
            data[i+1] *= updateVal;
            // data[i+2] *= updateVal;
            // data[i+3] *= updateVal;
        }
        const gridMouseX = Math.floor(mouse.x * sizeVal);
        const gridMouseY = Math.floor((1 - mouse.y) * sizeVal);
        for (let i = 0; i < sizeVal; i++) {
            for (let j = 0; j < sizeVal; j++) {
                    const distance = (gridMouseX - i) ** 2 + (gridMouseY - j) ** 2;
                    const maxDistSqr = maxDist ** 2;
                    if (distance < maxDistSqr) {
                        const index = 4 * (i + j * sizeVal);
                        let power;
                        if (distance < 1) {
                            power = 1;
                        } else {
                            power = 1 - (distance / maxDistSqr);
                        }
                        data[index] += 100 * mouse.vX * power;
                        data[index + 1] -= 100 * mouse.vY * power;
                        // data[index + 2] += 100* mouse.vX * power;
                        // data[index + 3] -= 100 * mouse.vY * power;
                    }
            }
        }
        mouse.vX *= updateVal;
        mouse.vY *= updateVal;
        dataTexture.needsUpdate = true;
    }

    const material =new THREE.RawShaderMaterial({
        uniforms: {
            u_time: { value: 0 },
            uFrequency: { value: new THREE.Vector2(10, 5) },
            uColor: { value: new THREE.Color('orange') },
            uDataTexture: {value: dataTexture},
            uResolution: { value: new THREE.Vector4(1,1,1,1) }, // TODO this needs to be adjusted to the actual screen size
            u_mouse: { value: new THREE.Vector2(0,0) }
        },
        vertexShader: vertex,
        fragmentShader: fragment
    })

    const pane = new THREE.Mesh(
        new THREE.PlaneGeometry(2, 2),
        material
    )

    scene.add(pane);

    const clock = new THREE.Clock();

    const animate = function () {
      requestAnimationFrame(animate);
      updateDataTexture();
      material.uniforms.u_time.value = clock.getElapsedTime();
      material.uniforms.u_mouse.value.x = mouse.x;
      material.uniforms.u_mouse.value.y = 1 - mouse.y;
      renderer.render(scene, camera);
    };

    animate();
  }, []);

  return (
    <canvas ref={canvasRef} />
  );
}