import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider, Chart, Flex, LabeledList } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const PDSRManipulator = (props, context) => {
  const { act, data } = useBackend(context);
  const { records } = data;
  const r_power_inputData = records.r_power_input.map((value, i) => [i, value]);
  const r_min_power_inputData = records.r_min_power_input.map((value, i) => [i, value]);
  const r_max_power_inputData = records.r_max_power_input.map((value, i) => [i, value]);
  return (
    <Window
      resizable
      theme="ntos"
      width={800}
      height={400}>
      <Window.Content scrollable>
        <Section>
          <Section title="Power Statistics">
            <Flex spacing={1}>
              <Flex.Item grow={1}>
                <Section position="relative" height="100%">
                  <Chart.Line
                    fillPositionedParent
                    data={r_power_inputData}
                    rangeX={[0, r_power_inputData.length - 1]}
                    rangeY={[0, data.r_max_power_input * 1.5]}
                    strokeColor="rgba(255, 255, 255, 1)"
                    fillColor="rgba(255, 255, 255, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={r_max_power_inputData}
                    rangeX={[0, r_max_power_inputData.length - 1]}
                    rangeY={[0, data.r_max_power_input * 1.5]}
                    strokeColor="rgba(0, 181, 173, 1)"
                    fillColor="rgba(0, 181, 173, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={r_min_power_inputData}
                    rangeX={[0, r_min_power_inputData.length - 1]}
                    rangeY={[0, data.r_max_power_input * 1.5]}
                    strokeColor="rgba(242, 113, 28, 1)"
                    fillColor="rgba(242, 113, 28, 0)" />
                </Section>
              </Flex.Item>
              <Flex.Item width="300px">
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Available Power">
                      <ProgressBar
                        value={data.available_power}
                        minValue={0}
                        maxValue={data.r_max_power_input * 1.25}
                        color="yellow" />
                    </LabeledList.Item>
                    <LabeledList.Item label="Input Power">
                      <Slider
                        value={data.r_power_input}
                        minValue={0}
                        maxValue={data.r_max_power_input * 1.25}
                        step={1}
                        stepPixelSize={1}
                        color="white"
                        onDrag={(e, value) => act('power_allocation', {
                          adjust: value,
                        })} />
                    </LabeledList.Item>
                    <LabeledList.Item label="Maximum Safe Power">
                      <ProgressBar
                        value={data.r_max_power_input}
                        minValue={0}
                        maxValue={data.r_max_power_input}
                        color="teal" />
                    </LabeledList.Item>
                    <LabeledList.Item label="Minimum Safe Power">
                      <ProgressBar
                        value={data.r_min_power_input}
                        minValue={0}
                        maxValue={data.r_max_power_input}
                        color="orange" />
                    </LabeledList.Item>
                    <LabeledList.Item label="Status:">
                      <Button
                        fluid
                        icon="shield-alt"
                        color={data.s_active ? "red" : "green"}
                        content={data.s_active ? "Offline" : "Online"} />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
          <Section title="Screen Manipulation">
            Screen Strength: {data.s_hardening}
            Screen Integrity:
            <ProgressBar
              value={data.s_integrity}
              range={{
                good: [],
                average: [0.15, 0.50],
                bad: [-Infinity, 0.15],
              }} />
            {data.s_integrity / 100 + ' %'}
            Screen Stability:
            <ProgressBar
              value={data.s_stability}
              range={{
                good: [],
                average: [0.33, 0.65],
                bad: [-Infinity, 0.33],
              }}>
              {data.s_stability / 100 + ' %'}
            </ProgressBar>
            Screen Hardening:
            <Slider
              value={data.s_hardening}
              fillValue={data.s_hardening}
              minValue={0}
              maxValue={100}
              step={1}
              stepPixelSize={1}
              onDrag={(e, value) => act('hardening', {
                input: value,
              })} />
            Screen Regeneration:
            <Slider
              value={data.s_regen}
              minValue={0}
              maxValue={100}
              step={1}
              stepPixelSize={1}
              onDrag={(e, value) => act('regen', {
                input: value,
              })} />
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
