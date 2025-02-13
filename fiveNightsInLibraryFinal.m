%% Intro: Display image and ask to start
introImage = imread("welcomeToTheLibrary.jpg");
imshow(introImage);
startStr = input("Would you like to start your shift (yes/no)? ", "s");
% Convert input to lowercase string for a simple comparison.
startStr = lower(strtrim(string(startStr)));
if startStr ~= "yes"
    disp("Wise choice, maybe you weren't cut out for this job.");
    return;
end
game = true;

%% Define floor settings and allowed cameras
floorOrder = ["bottom", "middle", "office"];
allowedCams.bottom = [1,2,3,4];
allowedCams.middle = [1,2,3];
allowedCams.office = [1,2];

%% Outer loop: Five nights (each night runs from 10 PM to 10 AM)
for night = 1:5
    if ~game, break; end  % Exit if game ended (player died)
    
    % Set difficulty for this night: 50%, 60%, …, 90%
    difficultyFactor = 0.4 + 0.1 * night;
    
    % For every night, Bereket starts on the bottom floor.
    suspectFloor = "bottom";
    cams = allowedCams.(suspectFloor);
    suspectLocation = cams(randi(numel(cams)));
    
    % Initialize time and locks:
    time24 = 22;  % 22:00 (10 PM)
    locksLeft = 3;
    
    fprintf("\n--- Night %i (Starting on the bottom floor) ---\n", night);
    disp("Your shift runs from 10:00 PM to 10:00 AM.");
    
    %% Inner loop: Simulate one night until time reaches 10 AM
    while game && time24 ~= 10
        % Display current time in 12-hour format:
        displayTime(time24);
        
        % Prompt for camera input using allowed cameras on the suspect's floor:
        currentAllowed = allowedCams.(suspectFloor);
        prompt = sprintf("Enter camera number %s: ", mat2str(currentAllowed));
        camera = input(prompt);
        if ~ismember(camera, currentAllowed)
            disp("Invalid camera number. Try again.");
            continue;
        end

        % --- Show the corresponding image and print status ---
        if camera == suspectLocation
            % Bereket spotted!
            filename = sprintf('camera%dBereket.jpg', camera);
            fprintf("Camera %d on the %s floor: You spotted the suspect!\n", camera, suspectFloor);
            
            % --- Process suspect movement when spotted ---
            if ~strcmp(suspectFloor, "bottom")
                % Retreat to the floor below.
                idx = find(strcmp(floorOrder, suspectFloor));
                newFloor = floorOrder{idx - 1};
                fprintf("Suspect spotted! Retreats from %s floor to %s floor.\n", suspectFloor, newFloor);
                suspectFloor = newFloor;
            else
                % On the bottom floor, move to another random camera.
                fprintf("Suspect spotted on the bottom floor! He moves to another camera.\n");
            end
            % Assign a random camera on the current floor.
            cams = allowedCams.(suspectFloor);
            suspectLocation = cams(randi(numel(cams)));
        else
            filename = sprintf('camera%d.jpg', camera);
            fprintf("Camera %d on the %s floor shows nothing unusual.\n", camera, suspectFloor);
            
            % --- Process suspect movement when not spotted ---
            if rand < difficultyFactor
                if strcmp(suspectFloor, "office")
                    % On the office floor, attempting to advance results in losing a lock.
                    fprintf("Suspect attempts to breach the office! You lose a lock.\n");
                    locksLeft = locksLeft - 1;
                    if locksLeft <= 0
                        try
                            imshow(imread("bereketDeath.jpg"));
                        catch
                            warning("Death image not found: bereketDeath.jpg");
                        end
                        [songAry, freq] = audioread("slenderman.mp3");
                        sound(songAry, freq);
                        disp("A shadowy figure approaches... you have been consumed!");
                        game = false;
                        return;
                    end
                    % After breaking a lock, Bereket moves to a random camera on the office floor.
                    cams = allowedCams.(suspectFloor);
                    suspectLocation = cams(randi(numel(cams)));
                else
                    % Advance to the next floor.
                    idx = find(strcmp(floorOrder, suspectFloor));
                    newFloor = floorOrder{idx + 1};
                    fprintf("Suspect advances from %s floor to %s floor.\n", suspectFloor, newFloor);
                    suspectFloor = newFloor;
                    % Assign a random camera on the new floor.
                    cams = allowedCams.(suspectFloor);
                    suspectLocation = cams(randi(numel(cams)));
                end
            else
                % Bereket remains on the current floor.
                fprintf("Suspect remains on the %s floor.\n", suspectFloor);
                % Assign a new random camera on the current floor.
                cams = allowedCams.(suspectFloor);
                suspectLocation = cams(randi(numel(cams)));
            end
        end
        
        % Display the image
        try
            imshow(imread(filename));
        catch
            warning("Image file not found: %s (photoshop remaining images if so inclined)", filename);
        end

        
        % % --- Show the corresponding image --- (update to have 7 different
        % % cameras corresponding to floors if so inclined)
        % if camera == suspectLocation
        %     % Bereket spotted!
        %     filename = sprintf('camera%dBereket.jpg', camera);
        %     fprintf("Camera %d on the %s floor: You spotted the suspect!\n", camera, suspectFloor);
        % else
        %     filename = sprintf('camera%d.jpg', camera);
        %     fprintf("Camera %d on the %s floor shows nothing unusual.\n", camera, suspectFloor);
        % end
        % try
        %     imshow(imread(filename));
        % catch
        %     warning("Image file not found: %s (photoshop remaining images if so inclined)", filename);
        % end
        % 
        % % --- Process suspect movement ---
        % if camera == suspectLocation
        %     % When spotted: Bereket retreats.
        %     if suspectFloor ~= "bottom"
        %         % Retreat to the floor below.
        %         idx = find(floorOrder == suspectFloor);
        %         newFloor = floorOrder(idx - 1);
        %         fprintf("Suspect spotted! Retreats from %s floor to %s floor.\n", suspectFloor, newFloor);
        %         suspectFloor = newFloor;
        %     else
        %         % On the bottom floor, move to another random camera.
        %         fprintf("Suspect spotted on the bottom floor! He moves to another camera.\n");
        %     end
        %     % Assign a random camera on the current floor.
        %     cams = allowedCams.(suspectFloor);
        %     suspectLocation = cams(randi(numel(cams)));
        % else
        %     % When not spotted, Bereket may try to advance.
        %     if rand < difficultyFactor
        %         if suspectFloor == "office"
        %             % On the office floor, attempting to advance results in losing a lock.
        %             fprintf("Suspect attempts to breach the office! You lose a lock.\n");
        %             locksLeft = locksLeft - 1;
        %             fprintf("Locks left: %i\n", locksLeft)
        %             if locksLeft <= 0
        %                 try
        %                     imshow(imread("bereketDeath.jpg"));
        %                 catch
        %                     warning("Death image not found: bereketDeath.jpg");
        %                 end
        %                 [songAry, freq] = audioread("slenderman.mp3");
        %                 sound(songAry, freq);
        %                 disp("A shadowy figure approaches... you have been consumed!");
        %                 game = false;
        %                 break;
        %             end
        %             % After breaking a lock, Bereket moves to a random camera on the office floor.
        %             cams = allowedCams.(suspectFloor);
        %             suspectLocation = cams(randi(numel(cams)));
        %         else
        %             % Advance to the next floor.
        %             idx = find(floorOrder == suspectFloor);
        %             newFloor = floorOrder(idx + 1);
        %             fprintf("Suspect advances from %s floor to %s floor.\n", suspectFloor, newFloor);
        %             suspectFloor = newFloor;
        %             % Assign a random camera on the new floor.
        %             cams = allowedCams.(suspectFloor);
        %             suspectLocation = cams(randi(numel(cams)));
        %         end
        %     else
        %         % Bereket remains on the current floor.
        %         fprintf("Suspect remains on the %s floor.\n", suspectFloor);
        %         % Assign a new random camera on the current floor.
        %         cams = allowedCams.(suspectFloor);
        %         suspectLocation = cams(randi(numel(cams)));
        %     end
        % end


        % --- Advance time by one hour ---
        time24 = time24 + 1;
        if time24 >= 24
            time24 = time24 - 24;
        end
    end  % end inner while (night simulation)
    
    if ~game, break; end
    fprintf("Night %i survived!\n", night);
    pause(1);  % Optional pause before next night
end  % end outer for (nights)

if game
    disp("Congratulations! You survived all five nights!");
end

%% Helper function: Display time in 12-hour format
function displayTime(time24)
    if time24 == 0
        fprintf("Time: 12 AM\n");
    elseif time24 < 12
        fprintf("Time: %i AM\n", time24);
    elseif time24 == 12
        fprintf("Time: 12 PM\n");
    else
        fprintf("Time: %i PM\n", time24 - 12);
    end
end