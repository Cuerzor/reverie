local UTF8 = {}

function UTF8.sub(str, i, j)
    if (not j) then
        j = string.len(str);
    end
    local offset = utf8.offset(str, i);
    local offsetj = utf8.offset(str, j + 1);
    return string.sub(str, offset, offsetj);
end

return UTF8;