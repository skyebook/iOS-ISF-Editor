/*
{
    "CREDIT": "by Skye Book",
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        }
    ]
}
 */

void main() {
    vec4 inputImagePixel = IMG_NORM_PIXEL(inputImage, vv_FragNormCoord);
    inputImagePixel.r = smoothstep(0.0, 0.5, abs(vv_FragNormCoord.x-0.5));
    inputImagePixel.g = smoothstep(0.0, 0.5, abs(vv_FragNormCoord.y-0.5));
    gl_FragColor = inputImagePixel;
}
