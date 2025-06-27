
// === LAYER.FX MODIFICADO COM BOTÃO DIREITO ===
#include "ReShade.fxh"

uniform float2 Layer_Pos <
    ui_label = "Layer Position";
    ui_type = "drag";
    ui_min = float2(0.0, 0.0);
    ui_max = float2(1.0, 1.0);
> = float2(0.5, 0.5);

uniform float Layer_Scale <
    ui_label = "Layer Scale";
    ui_min = 0.01;
    ui_max = 2.0;
> = 0.5;

uniform int HideOnRMB <
    ui_label = "Exibir apenas com botão direito";
    ui_type = "combo";
    ui_items = "Desativado\0Ativar (ocultar com RMB)\0Ativar (mostrar só com RMB)\0";
> = 0;

uniform int InvertHideOnRMB <
    ui_label = "Inverter lógica (debug)";
    ui_hidden = true;
> = 0;

// --- Textura usada como overlay ---
uniform texture LayerTex < source = "Layer.png"; >;

sampler LayerSampler { Texture = LayerTex; };

float4 PS_Layer(float4 pos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    bool show = true;
    #if __RESHADE__ >= 40000
        if (HideOnRMB != 0)
        {
            bool rmbDown = is_key_pressed(0x02); // 0x02 = botão direito do mouse
            if (HideOnRMB == 1) show = !rmbDown;
            else if (HideOnRMB == 2) show = rmbDown;
        }
    #endif

    if (!show) return float4(0, 0, 0, 0);

    // Escalando e posicionando a textura
    float2 center = Layer_Pos;
    float2 scale = float2(Layer_Scale, Layer_Scale);
    float2 coords = (texcoord - center) / scale + 0.5;

    float4 color = tex2D(LayerSampler, coords);
    return color;
}

technique OverlayLayer
{
    pass
    {
        PixelShader = PS_Layer;
    }
}
