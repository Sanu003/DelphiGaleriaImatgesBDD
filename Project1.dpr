program Project1;

uses
  Vcl.Forms,
  Unit2 in 'Unit2.pas' {Form2},
  FRM_Image1 in 'FRM_Image1.pas' {FRM_Image},
  Bases1 in 'Bases1.pas' {Bases},
  FRM_alta_Imatge1 in 'FRM_alta_Imatge1.pas' {FRM_alta_Imatge},
  FRM_Imatge_Comic1 in 'FRM_Imatge_Comic1.pas' {FRM_Imatge_Comic},
  FRM_buscar_comic1 in 'FRM_buscar_comic1.pas' {FRM_buscar_comic};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TBases, Bases);
  Application.CreateForm(TFRM_Imatge_Comic, FRM_Imatge_Comic);
  Application.CreateForm(TFRM_buscar_comic, FRM_buscar_comic);
  Application.Run;
end.
