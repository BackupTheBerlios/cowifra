#!/usr/bin/perl

#testchange
sub translate () {
    my $string = shift;
    my $lang = shift;

    ($lang eq "de") && return $string;

	  #Home page
    ($lang eq "uk") && ($string eq "im Wizard Configuration Framework (CWF).") &&  return "at the wizard configuration framework (CWF).";
    ($lang eq "uk") && ($string eq "Mit Hilfe des CWF k&ouml;nnen Sie beliebige Unix/Linux Programmpakete (f&uuml;r die eine ") && return "With the CWF you can configure any Unix/Linux application (if ";
    ($lang eq "uk") && ($string eq "CWF-Datei exististiert) Schritt f&uuml;r Schritt konfigurieren und ") && return " a wizard-file exists). You will find an easy to use step by step configuration ";
    ($lang eq "uk") && ($string eq "erhalten auf Wunsch zu jedem einzelnen Schritt weitergehenden Informationen.") && return " with lots of information for each step."; 
	  ($lang eq "uk") && ($string eq "Um jetzt mit der Konfiguration eines Programmpaketes zu beginnen, ") && return "If you would like to start now with the configuration of an application "; 
	  ($lang eq "uk") && ($string eq "w&auml;hlen Sie bitte einen Wizard aus der Liste auf der linken Seite aus.") && return "please choose one of the available wizards on the left side.";
	  ($lang eq "uk") && ($string eq "Im Hauptmen&uuml; unter dem Punkt &quot;Hilfe&quot; erhalten Sie mehr") && return "For more information about using the CWF,";
	  ($lang eq "uk") && ($string eq "Informationen zur Bedienung des CWF") && return "click the &quot;Help&quot; link in the mainmenue";

    #Mainmenue
    ($lang eq "uk") && ($string eq "Hauptmen&uuml;") &&  return "Mainmenu";
    ($lang eq "uk") && ($string eq "Hauptmen&uuml;anzeige an/aus") && return "Mainmenu on/off";
    ($lang eq "uk") && ($string eq "Startseite") &&  return "Home"; 
    ($lang eq "uk") && ($string eq "Zur&uuml;ck zum Hauptmen&uuml;") && return "Back to mainmenu"; 
    ($lang eq "uk") && ($string eq "Hilfe") && return "Help";
    ($lang eq "uk") && ($string eq "Online Hilfe") && return "Onscreen help";
    ($lang eq "uk") && ($string eq "Alle Icons gross") && return "Show big icons";	
    ($lang eq "uk") && ($string eq "Alle Icons klein") && return "Show small icons";	
    ($lang eq "uk") && ($string eq "Kein Icons") && return "Show no icons";	
    ($lang eq "uk") && ($string eq "Anf&auml;nger") && return "Beginner";	
    ($lang eq "uk") && ($string eq "Fortgeschr.") && return "Advanced";	
    ($lang eq "uk") && ($string eq "Profi") && return "Professional";	
    ($lang eq "uk") && ($string eq "Senden") && return "Send";	
    
    ($lang eq "uk") && ($string eq "Sprache") && return "Language";
    ($lang eq "uk") && ($string eq "Sprache: Deutsch") && return "Language: german";
    ($lang eq "uk") && ($string eq "Sprache: Englisch") && return "Language: english";
    ($lang eq "uk") && ($string eq "Zur&uuml;ck") && return "Back"; 

    ($lang eq "uk") && ($string eq "Verf&uuml;gbare Wizards") &&  return "Available Wizards";
    ($lang eq "uk") && ($string eq "Herzlich Willkommen, ") &&  return "Welcome, ";
    ($lang eq "uk") && ($string eq "> Startseite") &&  return "> Homepage ";
    ($lang eq "uk") && ($string eq "im Wizard Configuration Framework (CWF). Mit Hilfe des CWF k&ouml;nnen Sier beliebige Unix/Linux Programmpakete (f&uuml;r die eine CWF-Datei exististiert) Schritt f&uuml;r Schritt konfigurieren und erhalten auf Wunsch zu jedem einzelnen Schritt weitergehenden Informationen. Um jetzt mit der Konfiguration eines Programmpaketes zu beginnen, w&auml;hlen Sie bitte einen Wizard aus der Liste auf der linken Seite aus.") &&  return "to the wizard configuration framework (CWF). CWF will help you to cofigure linux/unix programms easily step by step.";

    #Sidemenu steps
    ($lang eq "uk") && ($string eq "Alle Konfigurationsschritte") &&  return "All wizard steps";
    ($lang eq "uk") && ($string eq "Verf&uuml;gbare Wizard Schritte anzeigen an/aus") && return "Show available wizard steps";
    ($lang eq "uk") && ($string eq "Kein Wizard verf&uuml;gbar (s. Hilfe f&uuml;r mehr Information)") && return "No wizard available, see help for more information";

    #Sidemenu cleanup
    ($lang eq "uk") && ($string eq "Aktionen am Ende der Konfiguration an/aus") &&  return "Actions at the end of the configuration";
    ($lang eq "uk") && ($string eq "Aktionen nach der Konfiguration") &&  return "Actions after configuration";
    ($lang eq "uk") && ($string eq "Aktion") &&  return "Action";

    #Sidemenu languages
    ($lang eq "uk") && ($string eq "Verf&uuml;gbare Wizard Sprachen") && return "Available wizard languages";
    ($lang eq "uk") && ($string eq "Verf&uuml;gbare Wizard Sprachen anzeigen") && return "Show available wizard languages";
    #($lang eq "uk") && ($string eq "aktiv") && return "active";
    
    #Sidemenu information
    ($lang eq "uk") && ($string eq "Informationen") && return "Information";
    ($lang eq "uk") && ($string eq "Fehler") && return "Error";

    #StartWizard
    ($lang eq "uk") && ($string eq "Informationen") && return "information";
    ($lang eq "uk") && ($string eq "f&uuml;r") && return "for";
    ($lang eq "uk") && ($string eq "Programm Packet") && return "Program package";
    ($lang eq "uk") && ($string eq "Programm Version") && return "Program version";
    ($lang eq "uk") && ($string eq "Konfigurationstyp") && return "Configuration type";
    ($lang eq "uk") && ($string eq "Dateipfade") && return "File paths";
    ($lang eq "uk") && ($string eq "Konfigurationsdatei") && return "Configuration file";
    ($lang eq "uk") && ($string eq "Konfigurationsprogramm") && return "Configuration tool";
    ($lang eq "uk") && ($string eq "Pfad existiert in diesem System") && return "Path exists";
    ($lang eq "uk") && ($string eq "Pfad existiert nicht in diesem System") && return "Path don\'t exists in this system";
    ($lang eq "uk") && ($string eq "Autor") && return "Author";
    ($lang eq "uk") && ($string eq "Datei") && return "File";
    ($lang eq "uk") && ($string eq "Datei gefunden") && return "File was found";
    ($lang eq "uk") && ($string eq "Datei nicht gefunden") && return "File was not found";
    ($lang eq "uk") && ($string eq "Wizard Datum") && return "Wizard date";
    ($lang eq "uk") && ($string eq "Weiterer Wizard") && return "Further wizard";
    ($lang eq "uk") && ($string eq "starten") && return "start";
    ($lang eq "uk") && ($string eq "Wizard mit allen Schritten starten") && return "Run wizard with all steps";
    ($lang eq "uk") && ($string eq "Die Datei") && return "The file";
    ($lang eq "uk") && ($string eq "wurde nicht in den angegebenen Verzeichnissen gefunden") && return "was not found in the given paths";
    ($lang eq "uk") && ($string eq "Ohne diese Datei kann der Wizard nicht gestartet werden.") && return "Without this file the wizard can\'t be started.";
    ($lang eq "uk") && ($string eq "Soll jetzt nach der Datei gesucht werden?") && return "Should I search your filesystem for this file?";	
    ($lang eq "uk") && ($string eq "Wizard nach Gruppe") && return "Start wizard grouped by theme";
    ($lang eq "uk") && ($string eq "Wizard nach Benutzerlevel") && return "Start wizard grouped by user level";
    ($lang eq "uk") && ($string eq "Sicherheitskopien der Konfigurationsdatei") && return "Backup of configuration file";
    ($lang eq "uk") && ($string eq "l&ouml;schen") && return "remove";
    ($lang eq "uk") && ($string eq "wiederherstellen") && return "restore";
    ($lang eq "uk") && ($string eq "Backup Datei konnte nicht gel&ouml;scht werden") && return "Couldn't remove backup file";
    ($lang eq "uk") && ($string eq "Backup Datei wurde gel&ouml;scht") && return "Backup file was removed";
    ($lang eq "uk") && ($string eq "Eine der beiden Dateien ist nicht vorhanden. Backup kann nicht wieder hergestellt werden.") && return "One of the files is not accessable. Can not restore backup.";
    ($lang eq "uk") && ($string eq "Backup erfolgreich wieder hergestellt.") && return "The backup file was successfully restored";
    ($lang eq "uk") && ($string eq "Ausf&uuml;hren") && return "Do it";
    ($lang eq "uk") && ($string eq "Konnte original Datei nicht umbenennen") && return "Couldn't rename original file";
    ($lang eq "uk") && ($string eq "Konnte Backup Datei nicht umbenennen") && return "Couldn't rename backup file";
    ($lang eq "uk") && ($string eq "Letzte &Auml;nderung") && return "Last changed";
    ($lang eq "uk") && ($string eq "Dateigr&ouml;sse") && return "File size";
    ($lang eq "uk") && ($string eq "Aktion nicht vorhanden") && return "Action not found";
    ($lang eq "uk") && ($string eq "Beim ausf&uuml;hren der Aktion trat ein Fehler auf") && return "Action has failed";
    ($lang eq "uk") && ($string eq "Aktion erfolgreich ausgef&uuml;hrt") && return "Action done successfully";
    ($lang eq "uk") && ($string eq "Alle Aktionen ausführen") && return "Run all actions";
    ($lang eq "uk") && ($string eq "Unbekannter Konfigurationstyp") && return "Unknown config type";
    

    #Steps
    ($lang eq "uk") && ($string eq "Schritt") && return "Step";	
    ($lang eq "uk") && ($string eq "Zur Wizard &Uuml;bersichtsseite") && return "Go to wizard index"; 
    ($lang eq "uk") && ($string eq "Kein Name") && return "No name";
    ($lang eq "uk") && ($string eq "Keine Hilfe f&uuml;r diesen Schritt verf&uuml;gbar") && return "No help available for this step";
    ($lang eq "uk") && ($string eq "Zum vorherigen Schritt") && return "Go to previous step";
    ($lang eq "uk") && ($string eq "Zun n&auml;chsten Schritt") && return "Go to next step";	
    ($lang eq "uk") && ($string eq "Es trat ein Fehler auf, dieser Konfigurationsschritt kann nicht ausgeführt werden") && return "Error, this step can not be done";	
    ($lang eq "uk") && ($string eq "Einstellung speichern") && return "Save value";	
    ($lang eq "uk") && ($string eq "Bitte ausw&auml;hlen") && return "Please choose";
    ($lang eq "uk") && ($string eq "Standard Wert") && return "Standard value";
    ($lang eq "uk") && ($string eq "Zur Zeit aktiv") && return "Active value";
    ($lang eq "uk") && ($string eq "Auskommentierter Wert") && return "Comment out value";
    ($lang eq "uk") && ($string eq "Wert angeben") && return "Enter value";
    ($lang eq "uk") && ($string eq "Wert nicht definieren") && return "Leave value empty";
    ($lang eq "uk") && ($string eq "Einstellung gespeichert") && return "Option saved";
    ($lang eq "uk") && ($string eq "Hinweis") && return "Hint";
    ($lang eq "uk") && ($string eq "Wert") && return "value";
    ($lang eq "uk") && ($string eq "Abh&auml;ngigkeiten") && return "Dependencies";
    ($lang eq "uk") && ($string eq "Folgende Schritte sollten ebenfalls durchgef&uuml;hrt werden, wenn Sie &Auml;nderungen in diesem Schritt vornehmen") && return "You should take a look at the following steps, if you change anything in this step";
    ($lang eq "uk") && ($string eq "Abh&auml;ngiger Schritt") && return "Depending step";
    ($lang eq "uk") && ($string eq "Abschnitt in Ihrer aktuellen Konfiguration noch nicht vorhanden") && return "This section is not present in your current configuration";
    ($lang eq "uk") && ($string eq "Abschnitt") && return "Section";
    ($lang eq "uk") && ($string eq "Abschnitt speichern") && return "Save section";
    ($lang eq "uk") && ($string eq "Als neuen Abschnitt speichern") && return "Save as new section";
    ($lang eq "uk") && ($string eq "Zum n&auml;chsten Schritt") && return "Goto next step";
    ($lang eq "uk") && ($string eq "F&uuml;r diesen Schritt existieren bereits mehrere Abschnitte.") && return "There are diffrent sections for this step.";
    ($lang eq "uk") && ($string eq "Sie k&ouml;nnen zwischen den einzelnen Abschnitten, mit Hilfe der Links neben dem Textfeld, w&auml;hlen") && return "Please switch between the sections by using the links near to the text field.	";
    ($lang eq "uk") && ($string eq "oder") && return "or";
    ($lang eq "uk") && ($string eq "und") && return "and";
    ($lang eq "uk") && ($string eq "Wert undefiniert lassen (Keine &Auml;nderung vornehmen)") && return "Don't set value (no change of current value)";
    ($lang eq "uk") && ($string eq "Ergebnis") && return "Result";
    ($lang eq "uk") && ($string eq "Ausgef&uuml;hrt") && return "Execute";
    ($lang eq "uk") && ($string eq "Ausschnitt") && return "Sample";
    ($lang eq "uk") && ($string eq "Unterschritte") && return "Subset";
    

    #Steps errors
    ($lang eq "uk") && ($string eq "Fehler im Wizard-File") && return "Error in wizard file";
    ($lang eq "uk") && ($string eq "Kann Konfigurationsdatei nicht finden") && return "Configuration file not found";
    ($lang eq "uk") && ($string eq "Kann Konfigurationsdatei nicht lesen") && return "Configuration file is not readable";
    ($lang eq "uk") && ($string eq "Einstellung konnte nicht ge&auml;ndert werden") && return "Could\'nt change option";
    ($lang eq "uk") && ($string eq "Einstellung konnte nicht gespeichert werden") && return "Could\'nt save to file";
    ($lang eq "uk") && ($string eq "Der Wert muss innerhalb bestimmter Zeichen stehen. Beispiel") && return "The value for this option must be quoted in special chars. Sample";
    ($lang eq "uk") && ($string eq "Bitte geben Sie einen Wert f&uuml;r diesen Schritt an") && return "Please enter a value for this step";
    ($lang eq "uk") && ($string eq "Bitte geben Sie einen Wert an") && return "Please enter a value";
    ($lang eq "uk") && ($string eq "Das angegeben Verzeichnis existiert nicht") && return "The specified directory does not exists";
    #($lang eq "uk") && ($string eq "Der Pfad muss absolut angegeben werden (beginnend mit /)") && return "Please enter the path in absolut format (start with /)";
    #($lang eq "uk") && ($string eq "Die Datei muss im absoluten Format angegeben werden (beginnend mit /)") && return "Please enter the file in absolut format (start with /)";
    ($lang eq "uk") && ($string eq "Die angegebene Datei existiert nicht") && return "The specified file does not exists";
    ($lang eq "uk") && ($string eq "Die Eingabe darf nur aus Buchstaben bestehen") && return "Your input should contain only letters";
    ($lang eq "uk") && ($string eq "Die Eingabe darf nur aus Ziffern bestehen") && return "Your input should contain only numbers";
    ($lang eq "uk") && ($string eq "Die Eingabe darf nur aus Ziffern, Buchstaben oder Unterstrichen bestehen") && return "Your input should contain only numbers, letters or underlines";
    ($lang eq "uk") && ($string eq "Die Eingabe muss eine IP sein (Format: 123.123.123.123)") && return "Your input should be a ip-adresse (format: 123.123.123.123)";
    ($lang eq "uk") && ($string eq "Die Eingabe muss eine E-Mail Adresse sein") && return "Your input should be an e-mail adress";
    ($lang eq "uk") && ($string eq "Es trat ein Fehler bei der Ausf&uuml;hrung auf, es wurden keine &Auml;nderungen durchgef&uuml;hrt") && return "An error occured, not changes was made";

    #Step Hints
    ($lang eq "uk") && ($string eq "Der Wert muss ein existierendes Verzeichnis sein") && return "The value has to be an existing directory";
    ($lang eq "uk") && ($string eq "Der Wert muss eine Datei sein") && return "The value must be a file";
    ($lang eq "uk") && ($string eq "Der Wert muss eine existierende Datei sein") && return "The value must be an existing file";
    ($lang eq "uk") && ($string eq "Der Wert darf nur Ziffern enthalten") && return "The value can only contain numbers";
    ($lang eq "uk") && ($string eq "Der Wert darf nur Buchstaben enthalten") && return "The value should only contain letters";
    ($lang eq "uk") && ($string eq "Der Wert darf nur Buchstaben, Zahlen oder Unterstriche enthalten") && return "The value should only contain letters, numbers or underlines";
    ($lang eq "uk") && ($string eq "Der Wert muss eine IP-Adresse sein. Beispiel:") && return "The value should be an ip-adress, sample:";
    ($lang eq "uk") && ($string eq "Der Wert muss eine E-Mail Adresse sein") && return "The value should be an e-mail adress";
		
    #Help
    ($lang eq "uk") && ($string eq "Inhalt") && return "Content";
    ($lang eq "uk") && ($string eq "Wizard Startseite") && return "Wizard startpage";
    ($lang eq "uk") && ($string eq "Wizard Schritt") && return "Wizard step";
    ($lang eq "uk") && ($string eq "Wizard Dateien") && return "Wizard files";
    ($lang eq "uk") && ($string eq "Willkommen") &&  return "Welcome";    
    
    

    return $string;

}

1;






