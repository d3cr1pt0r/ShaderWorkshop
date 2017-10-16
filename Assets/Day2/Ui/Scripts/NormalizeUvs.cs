using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class NormalizeUvs : BaseMeshEffect {

    public override void ModifyMesh(VertexHelper vh) {
        Rect rect = graphic.rectTransform.rect;
        float minY = rect.min.y;
        float maxY = rect.max.y;
        float minX = rect.min.x;
        float maxX = rect.max.x;

        int count = vh.currentVertCount;
        UIVertex uiVertex = new UIVertex();

        for (int i = 0; i < count; i++) {
            vh.PopulateUIVertex(ref uiVertex, i);

            float x = Mathf.InverseLerp(minX, maxX, uiVertex.position.x);
            float y = Mathf.InverseLerp(minY, maxY, uiVertex.position.y);

            uiVertex.uv1 = new Vector2(x, y);
            uiVertex.color = new Color32((byte)(x * 255), (byte)(y * 255), 0, 0);

            vh.SetUIVertex(uiVertex, i);
        }
    }

    public void Update() {
        var graphic = GetComponent<Graphic>();
        graphic.SetVerticesDirty();
    }

}