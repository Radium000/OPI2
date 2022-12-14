program Project2;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

type
  TArray = array [1 .. 10, 1 .. 10] of integer;

function readMatrixFromFile(const fileName: string): TArray;
var
  f: TextFile;
  s: string;
  i, j: integer;
begin
  for i := 1 to 10 do
    for j := 1 to 10 do
      Result[i, j] := 0;

  AssignFile(f, fileName);
  Reset(f);
  i := 1;
  while not Eof(f) do
  begin
    ReadLn(f, s);
    s := trim(s);
    if (pos('Ê', s) <> 0) and (pos('Ì', s) <> 0) then
    begin
      j := 1;
      while (j < Length(s)) do
      begin
        if s[j] = 'Ì' then
          Result[i, j] := 0
        else if s[j] = 'Ê' then
          Result[i, j] := -1
        else
        begin
          delete(s, j, 1);
          dec(j);
        end;
        Inc(j);
      end;

      Inc(i);
    end;
  end;
  CloseFile(f);
end;

begin

end.
