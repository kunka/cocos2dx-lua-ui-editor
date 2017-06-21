#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
    gl_FragColor = texture2D(CC_Texture0, v_texCoord) * v_fragmentColor;
    if(gl_FragColor.a > 0.0) {
        gl_FragColor.rgb *= 1.3;
    }
}
