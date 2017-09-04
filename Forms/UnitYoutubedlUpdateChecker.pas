{ *
  * Copyright (C) 2014-2017 ozok <ozok26@gmail.com>
  *
  * This file is part of TVideoDownloader.
  *
  * TVideoDownloader is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 2 of the License, or
  * (at your option) any later version.
  *
  * TVideoDownloader is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with TVideoDownloader.  If not, see <http://www.gnu.org/licenses/>.
  *
  * }
unit UnitYoutubedlUpdateChecker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdThreadComponent, JvComponentBase, JvThread, Vcl.ComCtrls, Vcl.Samples.Gauges, IdHashMessageDigest, IdHash;

type
  TYoutubedlUpdateChecker = class(TForm)
    OutputList: TMemo;
    CloseBtn: TButton;
    Downloader: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    UpdateThread: TJvThread;
    ProgressBar: TProgressBar;
    procedure CloseBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure UpdateThreadExecute(Sender: TObject; Params: Pointer);
    procedure DownloaderWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure DownloaderWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure DownloaderWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  private
    { Private declarations }
    FWorkSize: int64;
  public
    { Public declarations }
    Path: string;
    LocalVersion: string;
  end;

var
  YoutubedlUpdateChecker: TYoutubedlUpdateChecker;

const
  DOWNLOAD_PAGE_URL = 'https://rg3.github.io/youtube-dl/download.html';

implementation

{$R *.dfm}

uses
  UnitMain;

procedure TYoutubedlUpdateChecker.DownloaderWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  LPercent: integer;
begin
  if FWorkSize > 0 then
  begin
    LPercent := (100 * AWorkCount) div FWorkSize;
    ProgressBar.Position := LPercent;
  end;
end;

procedure TYoutubedlUpdateChecker.DownloaderWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  FWorkSize := AWorkCountMax;
end;

procedure TYoutubedlUpdateChecker.DownloaderWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
var
  LPath: string;
begin
  LPath := ChangeFileExt(Path, '.tmp');
  if FileExists(LPath) then
  begin

  end;
end;

procedure TYoutubedlUpdateChecker.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Downloader.Connected then
  begin
    Downloader.Disconnect;
  end;
  MainForm.Enabled := True;
end;

procedure TYoutubedlUpdateChecker.FormShow(Sender: TObject);
begin
  CloseBtn.Enabled := True;
  OutputList.Lines.Clear;
  ProgressBar.Position := 0;
  FWorkSize := 0;
  UpdateThread.Execute(nil);
end;

procedure TYoutubedlUpdateChecker.CloseBtnClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TYoutubedlUpdateChecker.UpdateThreadExecute(Sender: TObject; Params: Pointer);
const
  MATCH_LINE = '">Windows exe</a>';
  VERSION_LINE = '<h2><a href="https://yt-dl.org/downloads/';
  VERSION_LINE_END = '/youtube-dl">';
var
  LMS: TMemoryStream;
  LSR: TStreamReader;
  LLine: string;
  LPos: integer;
  LFS: TFileStream;
  LPath: string; // youtube-dl.tmp
  LContinue: Boolean;
  LExeLine: string;
  LDownloaded: Boolean;
begin
  // todo: do not access UI from thread
  OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] Starting the update process.');
  CloseBtn.Enabled := False;
  try
    LMS := TMemoryStream.Create;
    try
      OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] Checking for the update...');
      Downloader.Get(DOWNLOAD_PAGE_URL, LMS);
      LMS.Seek(0, soBeginning);
      LSR := TStreamReader.Create(LMS);
      try
        LContinue := True;
        while not LSR.EndOfStream do
        begin
          Application.ProcessMessages;
          LLine := LSR.ReadLine;

          // get the version number
          if LLine.contains(VERSION_LINE) then
          begin
            // if this string is longer than 0 it means called from
            // backend launcher
            if Length(LocalVersion) > 0 then
            begin
              LLine := LLine.Replace(VERSION_LINE, '');

              LPos := Pos(VERSION_LINE_END, LLine);
              if LPos > -1 then
              begin
                LLine := LLine.Substring(0, LPos - 1);
                OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] The Latest Version: ' + LLine);
                OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] The Local Version: ' + LocalVersion.Trim);
                LContinue := Trim(LLine) <> Trim(LocalVersion);
              end;
            end;
          end;

          // get the exe link
          if LLine.contains(MATCH_LINE) then
          begin
            LExeLine := LLine;
          end;
        end;
        if LContinue then
        begin
          if LExeLine.Length > 0 then
          begin
            LPos := Pos(MATCH_LINE, LExeLine);
            LExeLine := LExeLine.Substring(0, LPos - 1);
            LExeLine := StringReplace(LExeLine, '<a href="', '', []).Trim;
            OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] Link: ' + LExeLine);

            try
              LPath := ChangeFileExt(Path, '.tmp');
            // delete tmp file from a previous update
              if FileExists(LPath) then
              begin
                DeleteFile(LPath);
              end;
              try
            // write downloaded file to the tmp file
                LFS := TFileStream.Create(LPath, fmCreate);
                OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] Downloading the latest version...');
                Downloader.Get(LExeLine, LFS);
                OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] Downloaded the latest version.');
                if Length(LocalVersion) > 0 then
                begin
                  OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] This window will close itself now.');
                  Sleep(3000);
                end
                else
                begin
                  OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] You can close this window now.');
                end;
                LDownloaded := True;
              except
                on E: Exception do
                begin
                  OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] Error: ' + E.Message);
                  LDownloaded := False;
                end;
              end;
            finally
              LFS.Free;
              if LDownloaded then
              begin
              // delete the old version of the exe
                if FileExists(Path) then
                begin
                  DeleteFile(Path);
                end;
                RenameFile(LPath, Path);
              end;
            end;
          end
          else
          begin
            OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] Unable to get the link. Connect the author please.');
            LocalVersion := '';
          end;
        end
        else
        begin
          OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] You have the latest version.');
          OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] This window will close itself now.');
          Sleep(3000);
        end;
      finally
        LSR.Close;
        LSR.Free;
      end;
    except
      on E: Exception do
      begin
        OutputList.Lines.Add('[' + DateTimeToStr(Now) + '] Error: ' + E.Message)
      end;
    end;
  finally
    LMS.Free;
    CloseBtn.Enabled := True;
  end;

  UpdateThread.CancelExecute;
  if Params <> nil then
  begin
    Application.Terminate;
  end;
  if Length(LocalVersion) > 0 then
  begin
    Self.Close;
  end;
end;

end.



