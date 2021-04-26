import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider, Chart, Flex, LabeledList } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const PDSRManipulator = (props, context) => {
  const { act, data } = useBackend(context);
  const { records } = data;
  const r_reaction_polarityData = records.r_reaction_polarity.map((value, i) => [i, value]);
  const r_reaction_containmentData = records.r_reaction_containment.map((value, i) => [i, value]);
  return (
    <Window
      resizable
      theme="ntos"
      width={800}
      height={400}>
      <Window.Content scrollable>
        <Section>
          <Section title="Reactor Containment Statistics">
            <Flex spacing={1}>
              <Flex.Item grow={1}>
                <Section position="relative" height="100%">
                  <Chart.Line
                    fillPositionedParent
                    data={r_reaction_polarityData}
                    rangeX={[0, r_reaction_polarityData.length - 1]}
                    rangeY={[-1, 1]}
                    strokeColor="rgba(33, 133, 208, 1)"
                    fillColor="rgba(33, 133, 208, 0)" />
                  <Chart.Line
                    fillPostionedParent
                    data={r_reaction_containmentData}
                    rangeX={[0, r_reaction_containmentData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(255, 0, 0, 1)"
                    fillColor="rgba(255, 0, 0, 0)" />
                </Section>
              </Flex.Item>
              <Flex.Item width="300px">
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Reaction Polarity">
                      <ProgressBar
                        value={data.r_polarity}
                        minValue={-1}
                        maxValue={1}
                        colour="blue" />
                    </LabeledList.Item>
                    <LabeledList.Item label="Injection Polarity">
                      <Button
                        fluid
                        icon={data.r_polarity_injection ? "minus-circle" : "plus-circle"}
                        color={data.r_polarity_injection ? "black" : "white"}
                        content={data.r_polarity_injection ? "Negative" : "Positive"}
                        onClick={() => act('polarity')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Reaction Contaiment">
                      <ProgressBar
                        value={data.r_containment}
                        minValue={0}
                        maxValue={100}
                        colour="red" />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
          <Section title="Nucleium Injection">
            <Slider
              value={data.r_injection_rate}
              fillValue={data.r_injection_rate}
              minValue={0}
              maxValue={25}
              step={1}
              stepPixelSize={1}
              onDrag={(e, value) => act('injection_allocation', {
                adjust: value,
              })} />
          </Section>
          <Section title="Reaction Statistics">
            Temperature:
            <ProgressBar
              value={data.r_temp}
              range={{
                good: [],
                average: [0.5, 0.75],
                bad: [0.75, Infinity],
              }}>
              {toFixed(data.r_temp) + ' °C'}
            </ProgressBar>
            Reaction Rate:
            <ProgressBar
              value={data.r_reaction_rate}
              minValue={0}
              maxValue={50}
              color="primary" />
            Screen Capacity:
            <ProgressBar
              value={data.r_energy_output}
              minValue={0}
              maxValue={100}
              color="yellow" />
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
