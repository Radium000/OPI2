program Project2;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Windows;

type
  TMatrix = array [1 .. 10, 1 .. 10] of integer;
  TShip = array [1 .. 10] of string;

procedure ClearConsoleWindow;
var
  cursor: COORD;
  r: cardinal;
begin
  r := 300;
  cursor.X := 0;
  cursor.Y := 0;
  FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), ' ', 80 * r, cursor, r);
  SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursor);
end;

procedure SetColor(AColor: Integer);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), AColor and $0F);
end;

Function ConvertInputToCordinate(var Input: String): Boolean;
Var
  SetOfSigns: String;
  X, Y: integer;
  FoundX: Boolean;
  I, PosY, SignPos, CounterOfDigits: integer;
Begin
  SetOfSigns := 'АБВГДЕЖЗИК';
  FoundX := False;
  CounterOfDigits := 0;
  Input := AnsiUpperCase(Input);
  Result := True;

  For I := 1 To Length(Input) Do
  Begin
    SignPos := Pos(Input[I], SetOfSigns);

    If SignPos > 0 Then
    Begin
      If Not FoundX Then
      Begin
        FoundX := True;
        X := ord(Input[I]) - 1039;;
      End
      Else
      Begin
        If X <> ord(Input[I]) - 1039 Then
          Result := False;
      End;
    End
    Else
    Begin
      If ('0' < Input[I]) And (Input[I] <= '9') Then
      Begin
        Inc(CounterOfDigits);
        PosY := I;
      End;
    End;
  End;

  If FoundX Then
  Begin
    If (CounterOfDigits > 2) Or (CounterOfDigits < 1) Then
      Result := False
    Else
    Begin
      If CounterOfDigits = 1 Then
        Y := ord(Input[PosY]) - 48
      Else If (PosY = 1) or (Input[PosY] <> '0') or
        (Input[PosY - 1] <> '1') Then
        Result := False
      Else
        Y := 10;
    End;
  End
  Else
    Result := False;
  if Result then
  begin
    Input[1] := Char(Y);
    if (X < 10) then
      Input[2] := Char(X)
    else
      Input[2] := Char(10);
    Input:=Input[1]+Input[2];
  end
End;

function CheckCordsOnField(matrix: TMatrix; cords: string): Boolean;
const
  SetOfSigns = 'АБВГДЕЖЗИК';
var
  pos1, pos2: integer;
begin
  pos1 := ord(cords[1]);
  pos2 := ord(cords[2]);
  if matrix[pos1, pos2] > 1 then
  begin
    Result := False;
  end
  else
  begin
    Result := True;
  end;
end;

procedure IfKilled(var matrix: TMatrix; var ship_mas: TShip; cords: string);
var
  I, j: integer;
  flag: Boolean;
begin
  I := 1;
  while Pos(copy(cords, 1 ,2), ship_mas[I]) = 0 do
  begin
    I := I + 1;
  end;
  j := Pos(' ', ship_mas[I]);
  flag := True;
  while (j <= Length(ship_mas[I])) and flag do
  begin
    if matrix[ord(ship_mas[I][j - 2]), ord(ship_mas[I][j - 1])] <> 3 then
    begin
      flag := False
    end;
    j := j + 3
  end;
  if flag then
  begin
    j := Pos(' ', ship_mas[I]);
    while (j <= Length(ship_mas[I])) do
    begin
      matrix[ord(ship_mas[I][j - 2]), ord(ship_mas[I][j - 1])] := 4;
      j := j + 3
    end;
    ship_mas[I] := '';
  end;

end;

procedure ChangeField(var matrix: TMatrix; var cords: string; ship_mas: TShip);
const
  SetOfSigns = 'АБВГДЕЖЗИК';
var
  pos1, pos2: integer;
begin
  pos1 := ord(cords[1]);
  pos2 := ord(cords[2]);
  if matrix[pos1, pos2] = 0 then
  begin
    matrix[pos1, pos2] := 2;
  end
  else if matrix[pos1, pos2] = 1 then
  begin
    matrix[pos1, pos2] := 3;
    IfKilled(matrix, ship_mas, cords);
  end;

end;

function readMatrixFromFile(const fileName: string): TMatrix;
var
  f: TextFile;
  s: string;
  I, j: integer;

begin
  for I := 1 to 10 do
    for j := 1 to 10 do
      Result[I, j] := 0;

  AssignFile(f, fileName);
  Reset(f);
  I := 1;
  while (not Eof(f)) and (I <= 10) do
  begin
    ReadLn(f, s);
    j := 1;
    while (j <= Length(s)) and (j <= 10) do
    begin
      if ansilowercase(s[j]) = 'м' then
        Result[I, j] := 0
      else if ansilowercase(s[j]) = 'к' then
        Result[I, j] := -1
      else
      begin
        delete(s, j, 1);
        dec(j);
      end;
      Inc(j);
    end;

    Inc(I);
  end;
  CloseFile(f);
end;

function isCorrect(var field: TMatrix; var ships: TShip): Boolean;
var
  shipsNum: array [1 .. 5] of integer;
  I, j, count, dx, dy, x1, y1, ShipLength: integer;
  NewCords: string;
  correct: Boolean;
begin
  shipsNum[1] := 4;
  shipsNum[2] := 3;
  shipsNum[3] := 2;
  shipsNum[4] := 1;
  count := 1;
  correct := True;

  for I := 1 to 10 do
    for j := 1 to 10 do
    if correct then

    begin
      ShipLength := 1;
      if (field[I, j] < 0) and correct then
      begin
        field[I, j] := 1;
        ships[count] := char(I) + char(j) + ' ';
        NewCords := char(I) + char(j);
        y1 := I;
        x1 := j;
        repeat
          NewCords := '11';
          for dy := -1 to 1 do
            for dx := -1 to 1 do
              if (y1 + dy < 11) and (y1 + dy > 0) and (x1 + dx < 11) and
                (x1 + dx > 0) and correct then
              begin
                if abs(field[y1 + dy, x1 + dx]) = 1 then
                  if (dx and dy) = 0 then
                  begin
                    if field[y1 + dy, x1 + dx] = -1 then
                    begin
                      NewCords := char(y1 + dy) + char(x1 + dx);

                    end;
                  end
                  else
                    correct := False;
              end;
          if NewCords <> '11' then
          begin
            Inc(ShipLength);
            if ShipLength > 4 then
              correct := False
            else
            begin
              ships[count] := ships[count] + newcords[1] + newcords[2] + ' ';
              field[ord(newcords[1]), ord(newcords[2])] := 1;
              y1 := ord(newcords[1]);
              x1 := ord(newcords[2]);
            end;
          end;

        until NewCords = '11';
        shipsNum[ShipLength] := shipsNum[ShipLength] - 1;
        if shipsNum[ShipLength] < 0 then
          correct := False
        else
          Inc(count);

      end;
    end;
  if (shipsNum[1] <> 0) or (shipsNum[2] <> 0) or (shipsNum[3] <> 0) or
    (shipsNum[4] <> 0) then
    correct := False;
  Result := correct;
end;

procedure Render(field:TMatrix);
var i, j:integer;
begin

  writeln(' ');
  writeln('┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐');
  writeln('│   │ А │ Б │ В │ Г │ Д │ Е │ Ж │ З │ И │ К │');
  writeln('├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤');
  for I := 1 to 10 do
  begin
  write('│', i:2, ' ');
    for j := 1 to 10 do
    begin
      write('│');
      case field[I, j] of
        2:
        begin
        setcolor(2);
          write(' П ');
        setcolor(15);
        end;
        3:
          begin
        setcolor(14);
          write(' Р ');
        setcolor(15);
        end;
        4:
          begin
        setcolor(12);
          write(' У ');
        setcolor(15);
        end;
      else
        write('   ');

      end;
    end;
    writeln('│');
    if i<>10 then
    writeln('├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤');
  end;
  writeln('└───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘');

end;

procedure Game(var field: TMatrix; var ships: TShip; n: integer;
  var k: integer);
var
  I, j, p: integer;
  s: string;
begin
ClearConsoleWindow;
  writeln('ХОД ', n, '-ГО ИГРОКА');
  render(field);
  write(n, '-Й ИГРОК ВВЕДИТЕ КООРДИНАТЫ: ');
  ReadLN(s);
  repeat
     p := 0;
    if ConvertInputToCordinate(s) then
    begin
      if CheckCordsOnField(field, s) then
      begin
        ChangeField(field, s, ships);
        ClearConsoleWindow;
        writeln('ХОД ', n, '-ГО ИГРОКА');
        render(field);
        p := field[ord(s[1]), ord(s[2])];
        case p of
          2:
            writeln('Промах');
          3:
            writeln('Ранил');
          4:
            writeln('Убил');
        end;
        if ((p = 3) or (p = 4)) and (k<20) then
        begin
          k:=k+1;
          write(n, '-Й ИГРОК ВВЕДИТЕ КООРДИНАТЫ: ');
      ReadLn(s);
        end;
      end
      else
      begin
      ClearConsoleWindow;
      writeln('ХОД ', n, '-ГО ИГРОКА');
        render(field);
        writeln('Использованная клетка');
        write(n, '-Й ИГРОК ВВЕДИТЕ КООРДИНАТЫ: ');
      ReadLn(s);
      end;
    end
    else
      begin
      ClearConsoleWindow;
      writeln('ХОД ', n, '-ГО ИГРОКА');
        render(field);
        writeln('Неверные координаты');
        write(n, '-Й ИГРОК ВВЕДИТЕ КООРДИНАТЫ: ');
      ReadLn(s);
      end;
    if (p = 2) and (k<20) then
     begin
      writeln('Подтвердите ход следующего игрока' );
      ReadLn;

    end;
  until (k = 20) or (p = 2);

end;

var
  matrix1, matrix2: TMatrix;
  I, j, k1, k2: integer;
  ships1, ships2: TShip;

begin
  SetConsoleTitle(PChar('Морской бой'));
  matrix1 := readMatrixFromFile('field1.txt');
  matrix2 := readMatrixFromFile('field2.txt');

  if isCorrect(matrix1, ships1) then
    if isCorrect(matrix2, ships2) then
    begin
      k1:=0;
      k2:=0;
      repeat
        Game(matrix2, ships2, 1, k1);
        if k1 <> 20 then
          Game(matrix1, ships1, 2, k2);
      until (k1 = 20) or (k2 = 20);
      if k1 = 20 then
        writeln('Победил первый игрок!')
      else
        writeln('Победил второй игрок!')
    end
    else
      writeln('Матрица 2 некорректна')
  else
    writeln('Матрица 1 некорректна');

  ReadLn;

end.
