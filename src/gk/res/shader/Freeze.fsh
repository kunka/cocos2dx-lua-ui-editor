#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

void main(void)
{
    vec4 normalColor = texture2D(CC_Texture0, v_texCoord) * v_fragmentColor;
    float dt = CC_SinTime.w;
    float time = dt > 0.0 ? dt : -CC_SinTime.w;
    time = (time > 0.96 && dt > 0.0) ? (time*1.2) : (time/10.0 + 0.96);
    normalColor *= vec4(1.0-0.2*time, 1.0 +0.25*time, 1.0+0.25*time, 1.0 +0.25*time);
    normalColor.b += normalColor.a *  0.4*time;
    gl_FragColor = normalColor;
}
