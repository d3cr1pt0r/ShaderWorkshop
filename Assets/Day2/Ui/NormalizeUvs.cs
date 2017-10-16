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
            uiVertex.uv1 = new Vector2(Mathf.InverseLerp(minX, maxX, uiVertex.position.x), Mathf.InverseLerp(minY, maxY, uiVertex.position.y));
            vh.SetUIVertex(uiVertex, i);
        }
    }

}