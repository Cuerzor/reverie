local EmptyBook = THI.Collectibles.EmptyBook;
local Hidden = {

}
for i, id in pairs(EmptyBook.FinishedBooks) do
    table.insert(Hidden, id);
end

return Hidden;