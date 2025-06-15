unit MediaPlayer1;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.MPlayer;

type
  TMediaPlayer1 = class(TMediaPlayer)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TMediaPlayer1]);
end;

end.
