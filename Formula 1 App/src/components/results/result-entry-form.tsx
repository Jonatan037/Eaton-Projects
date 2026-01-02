'use client';

import { useState } from 'react';
import { useForm, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Plus, Trash2, Save, Loader2, Medal, Zap, Flag } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';
import { SessionTypeSchema, ResultStatusSchema } from '@/schemas';

// Form schema for result entries
const ResultEntrySchema = z.object({
  driverId: z.string().min(1, 'Driver is required'),
  teamId: z.string().min(1, 'Team is required'),
  position: z.coerce.number().int().positive().optional().nullable(),
  status: ResultStatusSchema,
  points: z.coerce.number().default(0),
  fastestLap: z.boolean().default(false),
  pole: z.boolean().default(false),
  notes: z.string().optional(),
});

const ResultFormSchema = z.object({
  roundId: z.string().min(1, 'Round is required'),
  sessionType: SessionTypeSchema,
  results: z.array(ResultEntrySchema).min(1, 'At least one result required'),
});

type ResultFormData = z.infer<typeof ResultFormSchema>;

interface Driver {
  id: string;
  fullName: string;
  gamertag: string;
  teamId: string;
  number?: number | null;
}

interface Team {
  id: string;
  name: string;
  primaryColor?: string | null;
}

interface Round {
  id: string;
  roundNumber: number;
  name?: string | null;
  track?: { name: string } | null;
}

interface ResultEntryFormProps {
  leagueId: string;
  drivers: Driver[];
  teams: Team[];
  rounds: Round[];
  scoringConfig?: Record<string, number>;
  onSubmit: (data: ResultFormData) => Promise<void>;
}

export function ResultEntryForm({
  leagueId,
  drivers,
  teams,
  rounds,
  scoringConfig,
  onSubmit,
}: ResultEntryFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const form = useForm<ResultFormData>({
    resolver: zodResolver(ResultFormSchema),
    defaultValues: {
      roundId: '',
      sessionType: 'RACE',
      results: [],
    },
  });

  const { fields, append, remove } = useFieldArray({
    control: form.control,
    name: 'results',
  });

  const selectedSessionType = form.watch('sessionType');

  // Get points for a position based on session type and scoring config
  const getPointsForPosition = (position: number | null | undefined, sessionType: string): number => {
    if (!position || !scoringConfig) return 0;
    
    const pointsMap = sessionType === 'SPRINT' 
      ? { 1: 8, 2: 7, 3: 6, 4: 5, 5: 4, 6: 3, 7: 2, 8: 1 }
      : { 1: 25, 2: 18, 3: 15, 4: 12, 5: 10, 6: 8, 7: 6, 8: 4, 9: 2, 10: 1 };
    
    return pointsMap[position as keyof typeof pointsMap] || 0;
  };

  // Add a new result row
  const addResultRow = () => {
    append({
      driverId: '',
      teamId: '',
      position: fields.length + 1,
      status: 'FINISHED',
      points: getPointsForPosition(fields.length + 1, selectedSessionType),
      fastestLap: false,
      pole: false,
      notes: '',
    });
  };

  // Auto-populate all drivers
  const populateAllDrivers = () => {
    const existingDriverIds = new Set(fields.map(f => form.getValues(`results.${fields.indexOf(f)}.driverId`)));
    
    drivers
      .filter(d => !existingDriverIds.has(d.id))
      .forEach((driver, idx) => {
        append({
          driverId: driver.id,
          teamId: driver.teamId,
          position: fields.length + idx + 1,
          status: 'FINISHED',
          points: 0,
          fastestLap: false,
          pole: false,
          notes: '',
        });
      });
  };

  // Handle form submission
  const handleSubmit = async (data: ResultFormData) => {
    setIsSubmitting(true);
    try {
      await onSubmit(data);
      form.reset();
    } catch (error) {
      console.error('Failed to submit results:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  // Get driver's team
  const getDriverTeam = (driverId: string): string => {
    const driver = drivers.find(d => d.id === driverId);
    return driver?.teamId || '';
  };

  // Auto-update team when driver is selected
  const handleDriverChange = (index: number, driverId: string) => {
    form.setValue(`results.${index}.driverId`, driverId);
    form.setValue(`results.${index}.teamId`, getDriverTeam(driverId));
  };

  // Auto-update points when position or status changes
  const handlePositionChange = (index: number, position: string) => {
    const pos = position ? parseInt(position) : null;
    form.setValue(`results.${index}.position`, pos);
    
    const status = form.getValues(`results.${index}.status`);
    if (status === 'FINISHED' && pos) {
      form.setValue(`results.${index}.points`, getPointsForPosition(pos, selectedSessionType));
    }
  };

  const handleStatusChange = (index: number, status: string) => {
    form.setValue(`results.${index}.status`, status as z.infer<typeof ResultStatusSchema>);
    
    if (status !== 'FINISHED') {
      form.setValue(`results.${index}.position`, null);
      form.setValue(`results.${index}.points`, 0);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Medal className="h-5 w-5 text-brand-neon" />
          Manual Result Entry
        </CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-6">
          {/* Round & Session Selection */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Round</Label>
              <Select
                value={form.watch('roundId')}
                onValueChange={(v) => form.setValue('roundId', v)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select round" />
                </SelectTrigger>
                <SelectContent>
                  {rounds.map((round) => (
                    <SelectItem key={round.id} value={round.id}>
                      Round {round.roundNumber}: {round.name || round.track?.name || 'TBD'}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              {form.formState.errors.roundId && (
                <p className="text-sm text-destructive">{form.formState.errors.roundId.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label>Session Type</Label>
              <Select
                value={form.watch('sessionType')}
                onValueChange={(v) => form.setValue('sessionType', v as z.infer<typeof SessionTypeSchema>)}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="QUALIFYING">Qualifying</SelectItem>
                  <SelectItem value="SPRINT">Sprint</SelectItem>
                  <SelectItem value="RACE">Race</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-2">
            <Button type="button" variant="outline" size="sm" onClick={addResultRow}>
              <Plus className="h-4 w-4 mr-1" />
              Add Row
            </Button>
            <Button type="button" variant="outline" size="sm" onClick={populateAllDrivers}>
              <Plus className="h-4 w-4 mr-1" />
              Add All Drivers
            </Button>
          </div>

          {/* Results Table */}
          {fields.length > 0 && (
            <div className="border rounded-lg overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-muted/50">
                    <tr>
                      <th className="px-3 py-2 text-left">Pos</th>
                      <th className="px-3 py-2 text-left">Driver</th>
                      <th className="px-3 py-2 text-left">Team</th>
                      <th className="px-3 py-2 text-left">Status</th>
                      <th className="px-3 py-2 text-left">Points</th>
                      <th className="px-3 py-2 text-center">FL</th>
                      <th className="px-3 py-2 text-center">Pole</th>
                      <th className="px-3 py-2"></th>
                    </tr>
                  </thead>
                  <tbody>
                    {fields.map((field, index) => {
                      const status = form.watch(`results.${index}.status`);
                      const fastestLap = form.watch(`results.${index}.fastestLap`);
                      const pole = form.watch(`results.${index}.pole`);
                      
                      return (
                        <tr 
                          key={field.id} 
                          className={cn(
                            'border-t',
                            status === 'DNF' && 'bg-red-500/10',
                            status === 'DSQ' && 'bg-yellow-500/10',
                            status === 'DNS' && 'bg-muted/30'
                          )}
                        >
                          <td className="px-3 py-2">
                            <Input
                              type="number"
                              min="1"
                              max="30"
                              className="w-16"
                              disabled={status !== 'FINISHED'}
                              {...form.register(`results.${index}.position`)}
                              onChange={(e) => handlePositionChange(index, e.target.value)}
                            />
                          </td>
                          <td className="px-3 py-2">
                            <Select
                              value={form.watch(`results.${index}.driverId`)}
                              onValueChange={(v) => handleDriverChange(index, v)}
                            >
                              <SelectTrigger className="w-44">
                                <SelectValue placeholder="Select driver" />
                              </SelectTrigger>
                              <SelectContent>
                                {drivers.map((driver) => (
                                  <SelectItem key={driver.id} value={driver.id}>
                                    {driver.number ? `#${driver.number} ` : ''}{driver.fullName}
                                  </SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                          </td>
                          <td className="px-3 py-2">
                            <Select
                              value={form.watch(`results.${index}.teamId`)}
                              onValueChange={(v) => form.setValue(`results.${index}.teamId`, v)}
                            >
                              <SelectTrigger className="w-36">
                                <SelectValue placeholder="Team" />
                              </SelectTrigger>
                              <SelectContent>
                                {teams.map((team) => (
                                  <SelectItem key={team.id} value={team.id}>
                                    <div className="flex items-center gap-2">
                                      {team.primaryColor && (
                                        <div 
                                          className="w-2 h-2 rounded-full"
                                          style={{ backgroundColor: team.primaryColor }}
                                        />
                                      )}
                                      {team.name}
                                    </div>
                                  </SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                          </td>
                          <td className="px-3 py-2">
                            <Select
                              value={status}
                              onValueChange={(v) => handleStatusChange(index, v)}
                            >
                              <SelectTrigger className="w-28">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="FINISHED">Finished</SelectItem>
                                <SelectItem value="DNF">DNF</SelectItem>
                                <SelectItem value="DNS">DNS</SelectItem>
                                <SelectItem value="DSQ">DSQ</SelectItem>
                              </SelectContent>
                            </Select>
                          </td>
                          <td className="px-3 py-2">
                            <Input
                              type="number"
                              min="0"
                              className="w-20"
                              {...form.register(`results.${index}.points`)}
                            />
                          </td>
                          <td className="px-3 py-2 text-center">
                            <Checkbox
                              checked={fastestLap}
                              onCheckedChange={(checked: boolean | 'indeterminate') => 
                                form.setValue(`results.${index}.fastestLap`, checked === true)
                              }
                              disabled={selectedSessionType !== 'RACE'}
                            />
                            {fastestLap && <Zap className="h-3 w-3 text-purple-500 inline ml-1" />}
                          </td>
                          <td className="px-3 py-2 text-center">
                            <Checkbox
                              checked={pole}
                              onCheckedChange={(checked: boolean | 'indeterminate') => 
                                form.setValue(`results.${index}.pole`, checked === true)
                              }
                              disabled={selectedSessionType !== 'QUALIFYING'}
                            />
                            {pole && <Flag className="h-3 w-3 text-brand-neon inline ml-1" />}
                          </td>
                          <td className="px-3 py-2">
                            <Button
                              type="button"
                              variant="ghost"
                              size="icon"
                              onClick={() => remove(index)}
                            >
                              <Trash2 className="h-4 w-4 text-destructive" />
                            </Button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* Submit Button */}
          <div className="flex justify-end gap-2">
            <Button type="button" variant="outline" onClick={() => form.reset()}>
              Clear
            </Button>
            <Button type="submit" variant="f1" disabled={isSubmitting || fields.length === 0}>
              {isSubmitting ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Saving...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4 mr-2" />
                  Save Results
                </>
              )}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
