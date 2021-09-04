if not (love or love.graphics) then
end

local verts = {
  { 0, -0.5, 0, 0, 1, 1, 1, 1 },
  { 1, -0.5, 0, 0, 1, 1, 1, 1 },

  { 0, 0.5, 0, 0, 1, 1, 1, 1 },
  { 1, 0.5, 0, 0, 1, 1, 1, 1 }
}

local seg = love.graphics.newMesh(verts, "strip", "static")

local line_shader = love.graphics.newShader([[
  attribute vec4 segment_coords;
  vec4 position(mat4 transform_projection, vec4 vertex_position){
    vec2 xBasis = segment_coords.zw - segment_coords.xy;
    vec2 yBasis = normalize(vec2(-xBasis.y, xBasis.x));
    vec2 point = segment_coords.xy + xBasis * vertex_position.x + yBasis * 2 * vertex_position.y;
    vertex_position.xy = point;
    return transform_projection * vertex_position;
  }
  ]])

return {
  new = function(line)
    local seg_coords = {}
    for i = 1, #line-3, 2 do
      table.insert(seg_coords, {line[i], line[i+1], line[i+2], line[i+3]})
    end

    return {len = #line/2-1, ia = love.graphics.newMesh({{"segment_coords", "float", 4}}, seg_coords, nil, "static")}
  end,

  draw = function(line)
    love.graphics.push("all")
    love.graphics.setShader(line_shader)
    seg:attachAttribute("segment_coords", line.ia, "perinstance")
    love.graphics.drawInstanced(seg, line.len)
    seg:detachAttribute("segment_coords")
    love.graphics.pop()
  end
}