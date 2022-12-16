local Base64 = LIB:NewClass();

local tool = LIB:Require("cuerlib/tools/base64");

function Base64.MakeEncoder(s62, s63, spad)
    return tool.makeencoder(s62, s63, spad);
end

function Base64.MakeDecoder(s62, s63, spad)
    return tool.makedecoder(s62, s63, spad);
end

function Base64.Encode(str, encoder, usecaching)
    return tool.encode(str, encoder, usecaching);
end

function Base64.Decode(b64, decoder, usecaching)
    return tool.decode(b64, decoder, usecaching);
end

return Base64;