unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FileCtrl, ComCtrls, ShellCtrls, Buttons,
  WinSkinData, Gauges, Clipbrd;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    ShellTreeView1: TShellTreeView;
    ComboExtensoes: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    ListView1: TListView;
    SkinData1: TSkinData;
    Label6: TLabel;
    GroupBox1: TGroupBox;
    MemoConteudo: TMemo;
    GroupBox2: TGroupBox;
    MemoArquivos: TMemo;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Gauge1: TGauge;
    Label4: TLabel;
    Label5: TLabel;
    Gauge2: TGauge;
    Label7: TLabel;
    Label8: TLabel;

    procedure PR_LocalizarTexto(const TextoBusca: String; var Texto: TMemo);

    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ComboExtensoesChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FSelPos: integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  F : TSearchRec;
  Ret : Integer;
  VAR_NomeArquivo : String;
  Numero: Array of integer;

implementation

uses Math;

{$R *.dfm}


Function Localizar(P:Pointer):LongInt; stdcall;
Var
  arq: TextFile;
  linha: String;
  VAR_Arquivo: String;

  i, Posicao, VAR_X, VAR_Existe : Integer;

  Listview : TListItem;
  Texto: TMemo;

 TextoBusca: String;
Begin

  VAR_X := High( Numero );

  TextoBusca := Form1.Edit1.Text;

  VAR_Arquivo := Form1.MemoArquivos.Lines.Strings[VAR_X];

  Texto := TMemo.Create(Application);
  //Texto.Clear;

  AssignFile (arq, Form1.ShellTreeView1.Path +'\'+ VAR_Arquivo);
//  Reset (arq);
  ReadLn(arq, linha);

  Texto.Text := UpperCase(Texto.Text) + linha + #13#10;

  while not Eof (arq) do
  begin
    ReadLn (arq, linha);
    Texto.Text := UpperCase(Texto.Text) + linha + #13#10;
  end;

  CloseFile (arq);

  For i:= 0 to Texto.Lines.count - 1 do
  begin
      Linha := Texto.Lines[i];
      Repeat
        Posicao := Pos(TextoBusca,Linha);

        If Posicao > 0 then
        Begin
          Texto.Lines[i] := Linha;

          if Form1.ListView1.Items.Count = 0 then
          begin
              Listview := Form1.ListView1.Items.Add;
              Listview.Caption := VAR_NomeArquivo;
              Listview.SubItems.Add(Form1.ShellTreeView1.Path +'\'+ VAR_NomeArquivo);
          end else begin

            VAR_X := 0;
            VAR_Existe := 0;
            
            while VAR_X < Form1.ListView1.Items.Count do //Verificar se já existe
            begin
              Listview := Form1.ListView1.Items.Item[VAR_X];

              if Listview.Caption = VAR_NomeArquivo then
              begin
                VAR_Existe := VAR_Existe + 1;
              end;

              VAR_X := VAR_X + 1;
            end;

            if VAR_Existe = 0 then //Só insere se não existir
            begin
              Listview := Form1.ListView1.Items.Add;
              Listview.Caption := VAR_NomeArquivo;
              Listview.SubItems.Add(Form1.ShellTreeView1.Path +'\'+ VAR_NomeArquivo);
            end;
          end;

          Posicao := 0;
        end;
      until Posicao = 0;
  end;
  //=========================

end;

Function ProcessaThread(P:Pointer):LongInt;
Var
  VAR_NuiArquivos, VAR_X : Integer;
  hThreadID : THandle;
  ThreadID : DWORD;

  VAR_Arquivo: TextFile;
  VAR_Linha: String;

  i, Posicao, VAR_Existe, VAR_Y : Integer;
  Linha : string;
  Listview : TListItem;
begin
  if Form1.MemoArquivos.Lines.Count = 0 then
  begin
    Form1.Label6.Caption := 'Nenhum Arquivo Encontrado!';
    Exit;
  end;

  Form1.ListView1.Clear;

  VAR_NuiArquivos := Form1.MemoArquivos.Lines.Count;
  VAR_X := 0;

  Form1.Gauge1.MinValue := 0;
  Form1.Gauge1.MaxValue := VAR_NuiArquivos;
  Form1.Gauge1.Progress := 0;

  while VAR_X < VAR_NuiArquivos do
  begin
    try
    VAR_NomeArquivo := Form1.MemoArquivos.Lines.Strings[VAR_X];

    //Form1.MemoConteudo.Lines.LoadFromFile(Form1.ShellTreeView1.Path +'\'+ Form1.MemoArquivos.Lines.Strings[VAR_X]);

    SetLength(Numero, high( Numero ) + 1);

    Form1.Label5.Caption := 'Atual: '+IntToStr(VAR_X + 1);
    Form1.Label7.Caption := 'Nome: '+Form1.MemoArquivos.Lines.Strings[VAR_X];

    AssignFile(VAR_Arquivo, Form1.ShellTreeView1.Path +'\'+ Form1.MemoArquivos.Lines.Strings[VAR_X]);
    Reset(VAR_Arquivo);
    //Form1.RichEdit1.Clear;
    //Form1.MemoConteudo.Clear;

    //Form1.RichEdit1.Lines.Add(VAR_Arquivo);
    //Form1.MemoConteudo.Lines.Append(VAR_Arquivo);

    while not EOF(VAR_Arquivo) do
    begin
      ReadLn(VAR_Arquivo, VAR_Linha);

      //Form1.RichEdit1.Text := Form1.RichEdit1.Text + VAR_Linha;
      //Form1.MemoConteudo.Lines.Add(VAR_Linha);

       if Pos(UpperCase(Form1.Edit1.Text),UpperCase(VAR_Linha)) > 0 then
      begin
        if Form1.ListView1.Items.Count = 0 then
        begin

            Listview := Form1.ListView1.Items.Add;
            Listview.Caption := VAR_NomeArquivo;
            Listview.SubItems.Add(Form1.ShellTreeView1.Path +'\'+ VAR_NomeArquivo);

        end else begin

          VAR_Y := 0;
          VAR_Existe := 0;

          while VAR_Y < Form1.ListView1.Items.Count do //Verificar se já existe
          begin

            if Form1.ListView1.Items.Item[VAR_Y].Caption = VAR_NomeArquivo then
            begin
              VAR_Existe := VAR_Existe + 1;
            end;

            VAR_Y := VAR_Y + 1;
          end;

          if VAR_Existe = 0 then //Só insere se não existir
          begin
            Listview := Form1.ListView1.Items.Add;
            Listview.Caption := VAR_NomeArquivo;
            Listview.SubItems.Add(Form1.ShellTreeView1.Path +'\'+ VAR_NomeArquivo);
          end;
        end;
      end;
    end;

    CloseFile(VAR_Arquivo);

    //Form1.MemoConteudo.Text := UpperCase(Form1.RichEdit1.Text);

    Form1.Label8.Caption := 'Linhas: '+IntToStr(Form1.MemoConteudo.Lines.Count);
    Form1.Gauge2.MaxValue := Form1.MemoConteudo.Lines.Count;
    Form1.Gauge2.MinValue := 0;

    //Form1.PR_LocalizarTexto(Form1.Edit1.Text, Form1.MemoConteudo);

    VAR_X := VAR_X + 1;
    Form1.Gauge1.Progress := VAR_X;
    except on e: exception do
      begin
        Form1.Label6.Caption := 'Erro inesperado no processo!!!';
      end;
    end;
  end;
end;


procedure TForm1.PR_LocalizarTexto(const TextoBusca: String; var Texto: TMemo);
Var
  i, Posicao, VAR_X, VAR_Existe : Integer;
  Linha : string;
  Listview : TListItem;
Begin
  For i:= 0 to Texto.Lines.count - 1 do
  begin
      Gauge2.Progress := i;
      Linha := Texto.Lines[i];
      Repeat
        Posicao := Pos(TextoBusca,Linha);
        If Posicao > 0 then
        Begin
          Texto.Lines[i] := Linha;

          if ListView1.Items.Count = 0 then
          begin
              Listview := ListView1.Items.Add;
              Listview.Caption := VAR_NomeArquivo;
              Listview.SubItems.Add(ShellTreeView1.Path +'\'+ VAR_NomeArquivo);
          end else begin

            VAR_X := 0;
            VAR_Existe := 0;

            while VAR_X < ListView1.Items.Count do //Verificar se já existe
            begin
              Listview := ListView1.Items.Item[VAR_X];

              if Listview.Caption = VAR_NomeArquivo then
              begin
                VAR_Existe := VAR_Existe + 1;
              end;

              VAR_X := VAR_X + 1;
            end;

            if VAR_Existe = 0 then //Só insere se não existir
            begin
              Listview := ListView1.Items.Add;
              Listview.Caption := VAR_NomeArquivo;
              Listview.SubItems.Add(ShellTreeView1.Path +'\'+ VAR_NomeArquivo);
            end;
          end;

          Posicao := 0;
        end;
      until Posicao = 0;
  end;
  Gauge2.Progress := Gauge2.MaxValue;
end;



procedure TForm1.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
var
  VAR_Extensao : String;
begin
  ComboExtensoes.Clear;

  Ret := FindFirst(ShellTreeView1.Path + '\*.*', faAnyFile, F);
  try

    while Ret = 0 do
    begin
      VAR_Extensao := Copy(F.Name, length(F.Name) - 3, 4);

      if (VAR_Extensao <> '.') and (VAR_Extensao <> '..') then
      begin
        if (ComboExtensoes.Items.IndexOf('*' + VAR_Extensao) < 0) then
        begin
          ComboExtensoes.Items.Add('*' + VAR_Extensao);
        end;
      end;

      Ret := FindNext(F);
    end;

    finally
    begin
      FindClose(F);
    end;
  end;
end;



procedure TForm1.ComboExtensoesChange(Sender: TObject);
begin
  MemoArquivos.Clear;
  MemoConteudo.Clear;
  ListView1.Clear;

  if ComboExtensoes.Text <> '' then
  begin
    Ret := FindFirst(ShellTreeView1.Path +'\'+ ComboExtensoes.Text, faAnyFile, F);
    try

      while Ret = 0 do
      begin
        MemoArquivos.Lines.Add(F.Name);
        Ret := FindNext(F);
       end;

      finally
      begin
        FindClose(F);
      end;
    end;
  end;
  Form1.Label6.Caption := IntToStr(Form1.MemoArquivos.Lines.Count)+' arquivos encontrados!!!';
  Form1.Label4.Caption := 'Arquivos: '+IntToStr(Form1.MemoArquivos.Lines.Count);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
Var
  hThreadID : THandle;
  ThreadID : DWORD;
begin
  hThreadID := CreateThread(nil,0, @ProcessaThread, nil, 0 , ThreadID);
end;

procedure TForm1.ListView1DblClick(Sender: TObject);
Var
  VAR_Arquivo : String;
begin
  VAR_Arquivo := ListView1.Items.Item[ListView1.Selected.index].SubItems.Strings[0];

  WinExec(PChar('C:\\WINDOWS\\system32\\notepad.exe ' + ListView1.Items.Item[ListView1.Selected.index].SubItems.Strings[0]),SW_NORMAL);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  SkinData1.SkinFile := ExtractFilePath(Application.ExeName) + 'skin\skin.skn';
//  SkinData1.Active := True;
end;

end.
