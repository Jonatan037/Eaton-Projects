'use client';

import { useState, useCallback } from 'react';
import { Upload, FileText, AlertCircle, CheckCircle2, X, Loader2, Download, Eye } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from '@/components/ui/dialog';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { ScrollArea } from '@/components/ui/scroll-area';
import { cn } from '@/lib/utils';
import { 
  parseResultsCSV, 
  validateAgainstLeague, 
  groupResultsByRound,
  generateCSVTemplate,
  type CSVParseResult,
  type CSVResultRow,
  type LeagueValidationContext,
} from '@/lib/csv-parser';

interface CSVImportModalProps {
  leagueId: string;
  leagueContext: LeagueValidationContext;
  onImport: (data: CSVResultRow[]) => Promise<void>;
  trigger?: React.ReactNode;
}

type ImportStep = 'upload' | 'preview' | 'confirm';

export function CSVImportModal({
  leagueId,
  leagueContext,
  onImport,
  trigger,
}: CSVImportModalProps) {
  const [open, setOpen] = useState(false);
  const [step, setStep] = useState<ImportStep>('upload');
  const [parseResult, setParseResult] = useState<CSVParseResult | null>(null);
  const [leagueErrors, setLeagueErrors] = useState<{ row: number; field: string; message: string }[]>([]);
  const [isImporting, setIsImporting] = useState(false);
  const [isDragOver, setIsDragOver] = useState(false);

  // Reset state when dialog closes
  const handleOpenChange = (isOpen: boolean) => {
    setOpen(isOpen);
    if (!isOpen) {
      setStep('upload');
      setParseResult(null);
      setLeagueErrors([]);
    }
  };

  // Handle file drop/select
  const handleFile = useCallback((file: File) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const content = e.target?.result as string;
      const result = parseResultsCSV(content);
      setParseResult(result);

      // Validate against league data
      if (result.success && result.data.length > 0) {
        const errors = validateAgainstLeague(result.data, leagueContext);
        setLeagueErrors(errors);
      }

      setStep('preview');
    };
    reader.readAsText(file);
  }, [leagueContext]);

  // Drag and drop handlers
  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragOver(true);
  };

  const handleDragLeave = () => {
    setIsDragOver(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragOver(false);
    const file = e.dataTransfer.files[0];
    if (file && file.type === 'text/csv') {
      handleFile(file);
    }
  };

  const handleFileInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      handleFile(file);
    }
  };

  // Download template
  const downloadTemplate = () => {
    const template = generateCSVTemplate();
    const blob = new Blob([template], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'results-import-template.csv';
    a.click();
    URL.revokeObjectURL(url);
  };

  // Handle import
  const handleImport = async () => {
    if (!parseResult?.data) return;
    
    setIsImporting(true);
    try {
      await onImport(parseResult.data);
      handleOpenChange(false);
    } catch (error) {
      console.error('Import failed:', error);
    } finally {
      setIsImporting(false);
    }
  };

  // Group results for preview
  const groupedResults: Map<number, Map<string, CSVResultRow[]>> = parseResult?.data 
    ? groupResultsByRound(parseResult.data) 
    : new Map<number, Map<string, CSVResultRow[]>>();

  const hasErrors = (parseResult?.errors.length ?? 0) > 0 || leagueErrors.length > 0;
  const hasWarnings = (parseResult?.warnings.length ?? 0) > 0;

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger asChild>
        {trigger || (
          <Button variant="outline">
            <Upload className="h-4 w-4 mr-2" />
            Import CSV
          </Button>
        )}
      </DialogTrigger>
      <DialogContent className="max-w-4xl max-h-[90vh] flex flex-col">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <FileText className="h-5 w-5" />
            Import Results from CSV
          </DialogTitle>
          <DialogDescription>
            Upload a CSV file with race results. Download the template for the correct format.
          </DialogDescription>
        </DialogHeader>

        {/* Step: Upload */}
        {step === 'upload' && (
          <div className="space-y-4">
            {/* Drop Zone */}
            <div
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              onDrop={handleDrop}
              className={cn(
                'border-2 border-dashed rounded-lg p-8 text-center transition-colors',
                isDragOver ? 'border-brand-neon bg-brand-neon/10' : 'border-muted-foreground/25',
                'hover:border-brand-neon/50'
              )}
            >
              <Upload className="h-10 w-10 mx-auto mb-4 text-muted-foreground" />
              <p className="text-lg font-medium mb-2">
                Drag and drop your CSV file here
              </p>
              <p className="text-sm text-muted-foreground mb-4">
                or click to browse
              </p>
              <input
                type="file"
                accept=".csv"
                onChange={handleFileInput}
                className="hidden"
                id="csv-upload"
              />
              <label htmlFor="csv-upload">
                <Button variant="outline" asChild>
                  <span>Browse Files</span>
                </Button>
              </label>
            </div>

            {/* Template Download */}
            <div className="flex items-center justify-between p-4 bg-muted/50 rounded-lg">
              <div>
                <p className="font-medium">Need a template?</p>
                <p className="text-sm text-muted-foreground">
                  Download our CSV template with example data
                </p>
              </div>
              <Button variant="outline" size="sm" onClick={downloadTemplate}>
                <Download className="h-4 w-4 mr-2" />
                Download Template
              </Button>
            </div>
          </div>
        )}

        {/* Step: Preview */}
        {step === 'preview' && parseResult && (
          <div className="flex-1 overflow-hidden flex flex-col space-y-4">
            {/* Status Summary */}
            <div className="flex gap-2 flex-wrap">
              <Badge variant={parseResult.success && !hasErrors ? 'default' : 'destructive'}>
                {parseResult.data.length} rows parsed
              </Badge>
              {parseResult.errors.length > 0 && (
                <Badge variant="destructive">
                  {parseResult.errors.length} parse errors
                </Badge>
              )}
              {leagueErrors.length > 0 && (
                <Badge variant="destructive">
                  {leagueErrors.length} validation errors
                </Badge>
              )}
              {hasWarnings && (
                <Badge variant="secondary">
                  {parseResult.warnings.length} warnings
                </Badge>
              )}
            </div>

            {/* Errors & Warnings */}
            {hasErrors && (
              <Alert variant="destructive">
                <AlertCircle className="h-4 w-4" />
                <AlertTitle>Errors Found</AlertTitle>
                <AlertDescription>
                  <ScrollArea className="h-24 mt-2">
                    <ul className="list-disc list-inside space-y-1 text-sm">
                      {parseResult.errors.map((err, i) => (
                        <li key={`parse-${i}`}>
                          Row {err.row}: {err.field} - {err.message}
                          {err.value && <span className="text-muted-foreground"> (value: "{err.value}")</span>}
                        </li>
                      ))}
                      {leagueErrors.map((err, i) => (
                        <li key={`league-${i}`}>
                          Row {err.row}: {err.field} - {err.message}
                        </li>
                      ))}
                    </ul>
                  </ScrollArea>
                </AlertDescription>
              </Alert>
            )}

            {hasWarnings && !hasErrors && (
              <Alert>
                <AlertCircle className="h-4 w-4" />
                <AlertTitle>Warnings</AlertTitle>
                <AlertDescription>
                  <ul className="list-disc list-inside space-y-1 text-sm mt-2">
                    {parseResult.warnings.map((warn, i) => (
                      <li key={i}>Row {warn.row}: {warn.message}</li>
                    ))}
                  </ul>
                </AlertDescription>
              </Alert>
            )}

            {/* Preview Tabs by Round */}
            {parseResult.data.length > 0 && (
              <Tabs defaultValue={`round-${Array.from(groupedResults.keys())[0]}`} className="flex-1 overflow-hidden">
                <TabsList className="w-full justify-start flex-wrap h-auto gap-1 p-1">
                  {Array.from(groupedResults.keys()).map((roundNum) => (
                    <TabsTrigger key={roundNum} value={`round-${roundNum}`}>
                      Round {roundNum}
                    </TabsTrigger>
                  ))}
                </TabsList>
                
                {Array.from(groupedResults.entries()).map(([roundNum, sessions]) => (
                  <TabsContent key={roundNum} value={`round-${roundNum}`} className="flex-1 overflow-auto">
                    <div className="space-y-4">
                      {Array.from(sessions.entries()).map(([sessionType, results]) => (
                        <div key={sessionType} className="border rounded-lg overflow-hidden">
                          <div className="bg-muted/50 px-3 py-2 font-medium flex items-center gap-2">
                            <Badge variant="outline">{sessionType}</Badge>
                            <span className="text-sm text-muted-foreground">
                              {results.length} entries
                            </span>
                          </div>
                          <table className="w-full text-sm">
                            <thead className="bg-muted/30">
                              <tr>
                                <th className="px-3 py-1.5 text-left">Pos</th>
                                <th className="px-3 py-1.5 text-left">Driver</th>
                                <th className="px-3 py-1.5 text-left">Team</th>
                                <th className="px-3 py-1.5 text-left">Status</th>
                                <th className="px-3 py-1.5 text-right">Points</th>
                                <th className="px-3 py-1.5 text-center">FL</th>
                                <th className="px-3 py-1.5 text-center">Pole</th>
                              </tr>
                            </thead>
                            <tbody>
                              {results.map((result, idx) => (
                                <tr key={idx} className="border-t">
                                  <td className="px-3 py-1.5">{result.position || '-'}</td>
                                  <td className="px-3 py-1.5">{result.driverFullName}</td>
                                  <td className="px-3 py-1.5">{result.teamName}</td>
                                  <td className="px-3 py-1.5">
                                    <Badge 
                                      variant={result.status === 'FINISHED' ? 'default' : 'destructive'}
                                      className="text-xs"
                                    >
                                      {result.status}
                                    </Badge>
                                  </td>
                                  <td className="px-3 py-1.5 text-right">{result.points}</td>
                                  <td className="px-3 py-1.5 text-center">
                                    {result.fastestLap && '⚡'}
                                  </td>
                                  <td className="px-3 py-1.5 text-center">
                                    {result.pole && '🏁'}
                                  </td>
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </div>
                      ))}
                    </div>
                  </TabsContent>
                ))}
              </Tabs>
            )}
          </div>
        )}

        <DialogFooter className="gap-2">
          {step === 'preview' && (
            <>
              <Button variant="outline" onClick={() => setStep('upload')}>
                <X className="h-4 w-4 mr-2" />
                Choose Different File
              </Button>
              <Button 
                variant="f1" 
                onClick={handleImport}
                disabled={hasErrors || isImporting || !parseResult?.data.length}
              >
                {isImporting ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Importing...
                  </>
                ) : (
                  <>
                    <CheckCircle2 className="h-4 w-4 mr-2" />
                    Import {parseResult?.data.length || 0} Results
                  </>
                )}
              </Button>
            </>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
