// CLASS CONSTANTS
// HT16K33 registers and HT16K33-specific variables
const HT16K33_MAT_CLASS_REGISTER_DISPLAY_ON  = "\x81"
const HT16K33_MAT_CLASS_REGISTER_DISPLAY_OFF = "\x80"
const HT16K33_MAT_CLASS_REGISTER_SYSTEM_ON   = "\x21"
const HT16K33_MAT_CLASS_REGISTER_SYSTEM_OFF  = "\x20"
const HT16K33_MAT_CLASS_DISPLAY_ADDRESS      = "\x00"
const HT16K33_MAT_CLASS_I2C_ADDRESS          = 0x70

class HT16K33Matrix {

    // Squirrel class for 1.2-inch 8x8 LED matrix displays driven by the HT16K33 controller
    // For example: http://www.adafruit.com/products/1854
    // Written by Tony Smith (@smittytone)
    // Issued under the MIT license (MIT)

    static VERSION = "1.2.5";

    // Proportionally space character set
    // NOTE Squirrel doesn't support array consts
    static _pcharset = [
    [0x00, 0x00],                   // space - Ascii 32
    [0xfa],                         // !
    [0xc0, 0x00, 0xc0],             // "
    [0x24, 0x7e, 0x24, 0x7e, 0x24], // #
    [0x24, 0xd4, 0x56, 0x48],       // $
    [0xc6, 0xc8, 0x10, 0x26, 0xc6], // %
    [0x6c, 0x92, 0x6a, 0x04, 0x0a], // &
    [0xc0],                         // '
    [0x7c, 0x82],                   // (
    [0x82, 0x7c],                   // )
    [0x10, 0x7c, 0x38, 0x7c, 0x10], // *
    [0x10, 0x10, 0x7c, 0x10, 0x10], // +
    [0x06, 0x07],                   // ,
    [0x10, 0x10, 0x10, 0x10, 0x10], // -
    [0x06, 0x06],                   // .
    [0x04, 0x08, 0x10, 0x20, 0x40], // /
    [0x7c, 0x8a, 0x92, 0xa2, 0x7c], // 0 - Ascii 48
    [0x42, 0xfe, 0x02],             // 1
    [0x46, 0x8a, 0x92, 0x92, 0x62], // 2
    [0x44, 0x92, 0x92, 0x92, 0x6c], // 3
    [0x18, 0x28, 0x48, 0xfe, 0x08], // 4
    [0xf4, 0x92, 0x92, 0x92, 0x8c], // 5
    [0x3c, 0x52, 0x92, 0x92, 0x8c], // 6
    [0x80, 0x8e, 0x90, 0xa0, 0xc0], // 7
    [0x6c, 0x92, 0x92, 0x92, 0x6c], // 8
    [0x60, 0x92, 0x92, 0x94, 0x78], // 9
    [0x36, 0x36],                   // : - Ascii 58
    [0x36, 0x37],                   // ;
    [0x10, 0x28, 0x44, 0x82],       // <
    [0x24, 0x24, 0x24, 0x24, 0x24], // =
    [0x82, 0x44, 0x28, 0x10],       // >
    [0x60, 0x80, 0x9a, 0x90, 0x60], // ?
    [0x7c, 0x82, 0xba, 0xaa, 0x78], // @
    [0x7e, 0x90, 0x90, 0x90, 0x7e], // A - Ascii 65
    [0xfe, 0x92, 0x92, 0x92, 0x6c], // B
    [0x7c, 0x82, 0x82, 0x82, 0x44], // C
    [0xfe, 0x82, 0x82, 0x82, 0x7c], // D
    [0xfe, 0x92, 0x92, 0x92, 0x82], // E
    [0xfe, 0x90, 0x90, 0x90, 0x80], // F
    [0x7c, 0x82, 0x92, 0x92, 0x5c], // G
    [0xfe, 0x10, 0x10, 0x10, 0xfe], // H
    [0x82, 0xfe, 0x82],             // I
    [0x0c, 0x02, 0x02, 0x02, 0xfc], // J
    [0xfe, 0x10, 0x28, 0x44, 0x82], // K
    [0xfe, 0x02, 0x02, 0x02, 0x02], // L
    [0xfe, 0x40, 0x20, 0x40, 0xfe], // M
    [0xfe, 0x40, 0x20, 0x10, 0xfe], // N
    [0x7c, 0x82, 0x82, 0x82, 0x7c], // O
    [0xfe, 0x90, 0x90, 0x90, 0x60], // P
    [0x7c, 0x82, 0x92, 0x8c, 0x7a], // Q
    [0xfe, 0x90, 0x90, 0x98, 0x66], // R
    [0x64, 0x92, 0x92, 0x92, 0x4c], // S
    [0x80, 0x80, 0xfe, 0x80, 0x80], // T
    [0xfc, 0x02, 0x02, 0x02, 0xfc], // U
    [0xf8, 0x04, 0x02, 0x04, 0xf8], // V
    [0xfc, 0x02, 0x3c, 0x02, 0xfc], // W
    [0xc6, 0x28, 0x10, 0x28, 0xc6], // X
    [0xe0, 0x10, 0x0e, 0x10, 0xe0], // Y
    [0x86, 0x8a, 0x92, 0xa2, 0xc2], // Z - Ascii 90
    [0xfe, 0x82, 0x82],             // [
    [0x40, 0x20, 0x10, 0x08, 0x04], // \
    [0x82, 0x82, 0xfe],             // ]
    [0x20, 0x40, 0x80, 0x40, 0x20], // ^
    [0x02, 0x02, 0x02, 0x02, 0x02], // _
    [0xc0, 0xe0],                   // '
    [0x04, 0x2a, 0x2a, 0x1e],       // a - Ascii 97
    [0xfe, 0x22, 0x22, 0x1c],       // b
    [0x1c, 0x22, 0x22, 0x22],       // c
    [0x1c, 0x22, 0x22, 0xfc],       // d
    [0x1c, 0x2a, 0x2a, 0x10],       // e
    [0x10, 0x7e, 0x90, 0x80],       // f
    [0x18, 0x25, 0x25, 0x3e],       // g
    [0xfe, 0x20, 0x20, 0x1e],       // h
    [0xbc, 0x02],                   // i
    [0x02, 0x01, 0x21, 0xbe],       // j
    [0xfe, 0x08, 0x14, 0x22],       // k
    [0xfc, 0x02],                   // l
    [0x3e, 0x20, 0x18, 0x20, 0x1e], // m
    [0x3e, 0x20, 0x20 0x1e],        // n
    [0x1c, 0x22, 0x22, 0x1c],       // o
    [0x3f, 0x22, 0x22, 0x1c],       // p
    [0x1c, 0x22, 0x22, 0x3f],       // q
    [0x22, 0x1e, 0x20, 0x10],       // r
    [0x12, 0x2a, 0x2a, 0x04],       // s
    [0x20, 0x7c, 0x22, 0x04],       // t
    [0x3c, 0x02, 0x02, 0x3e],       // u
    [0x38, 0x04, 0x02, 0x04, 0x38], // v
    [0x3c, 0x06, 0x0c, 0x06, 0x3c], // w
    [0x22, 0x14, 0x08, 0x14, 0x22], // x
    [0x39, 0x05, 0x06, 0x3c],       // y
    [0x26, 0x2a, 0x2a, 0x32],       // z - Ascii 122
    [0x10, 0x7c, 0x82, 0x82],       // {
    [0xee],                         // |
    [0x82, 0x82, 0x7c, 0x10],       // }
    [0x40, 0x80, 0x40, 0x80],       // ~
    [0x60, 0x90, 0x90, 0x60],       // Degrees sign - Ascii 127
    ];

    // Class private properties
    _buffer = null;
    _led = null;
    _defchars = null;

    _ledAddress = 0;
    _alphaCount = 96;
    _rotationAngle = 0;
    _rotateFlag = false;
    _inverseVideoFlag = false;
    _debug = false;
    _logger = null;

    _aStrings = null;
    _aTimer = null;
    _aCb = null;
    _aSliceIndex = 0;
    _aCharIndex = 0;
    _aSeqIndex = 0;
    _aFlag = true;

    constructor(impI2Cbus = null, i2cAddress = 0x70, debug = false) {
        // Parameters:
        //  1. Whichever configured imp I2C bus is to be used for the HT16K33
        //  2. The HT16K33's I2C address (default: 0x70)
        //  3. Boolean - set/unset to log/silence error messages
        //
        // Returns:
        //  HT16K33Matrix instance - errors throw

        if (impI2Cbus == null) throw "HT16K33Matrix() requires a non-null imp I2C object";
        if (i2cAddress < 0x00 || i2cAddress > 0xFF) throw "HT16K33Matrix() requires a valid I2C address";

        _led = impI2Cbus;
        _ledAddress = i2cAddress << 1;

        if (typeof debug != "bool") debug = false;
        _debug = debug;

        _buffer = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        //_defchars = array(32, -1);
        _defchars = {};

        // Select logging target, stored in '_logger' - this will point to 'seriallog' if 'seriallog.nut' has been
        // loaded BEFORE HT16K33Matrix is instantiated.
        // NOTE 'seriallog' also logs via server.log() as well as serial,
        //      so logs will not be lost if 'seriallog' is not configured
        if ("seriallog" in getroottable()) { _logger = seriallog; } else { _logger = server; }
    }

    function init(brightness = 15, angle = 0) {
        // Parameters:
        //   1. Display brightness, 1-15 (default: 15)
        //   2. Display auto-rotation angle, 0 to -360 degrees (default: 0)
        // Returns: Nothing

        // Angle range can be -360 to + 360 - ignore values beyond this
        if (angle < -360 || angle > 360) angle = 0;

        // Convert angle in degrees to internal value:
        // 0 = none, 1 = 90 clockwise, 2 = 180, 3 = 90 anti-clockwise
        if (angle < 0) angle = 360 + angle;

        if (angle > 3) {
            if (angle < 45 || angle > 360) angle = 0;
            if (angle >= 45 && angle < 135) angle = 1;
            if (angle >= 135 && angle < 225) angle = 2;
            if (angle >= 225) angle = 3
        }

        _rotationAngle = angle;
        if (_rotationAngle != 0) _rotateFlag = true;

        // Power up and set the brightness
        powerUp();
        setBrightness(brightness);
        clearDisplay();
    }

    function setBrightness(brightness = 15) {
        // Parameters: 1. Display brightness, 1-15 (default: 15)
        // Returns:    Nothing
        if (typeof brightness != "integer" && typeof brightness != "float") brightness = 15;
        brightness = brightness.tointeger();

        if (brightness > 15) {
            brightness = 15;
            if (_debug) _logger.error("HT16K33Segment.setBrightness() brightness out of range (0-15)");
        }

        if (brightness < 0) {
            brightness = 0;
            if (_debug) _logger.error("HT16K33Segment.setBrightness() brightness out of range (0-15)");
        }

        if (_debug) _logger.log("Brightness set to " + brightness);
        brightness = brightness + 224;

        // Write the new brightness value to the HT16K33
        _led.write(_ledAddress, brightness.tochar() + "\x00");
    }

    function clearDisplay() {
        // Parameters: None
        // Returns: Nothing
        _buffer = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        _writeDisplay();
    }

    function setInverseVideo(state = true) {
        // Parameters:
        //   1. Boolean: whether inverse video is set (true) or unset (false)
        // Returns: Nothing

        if (typeof state != "bool") state = true;
        _inverseVideoFlag = state;
        if (_debug) _logger.log(format("Switching the HT16K33 Matrix to %s", (state ? "inverse video" : "normal video")));
        _writeDisplay();
    }

    function displayIcon(glyphMatrix, center = false) {
        // Displays a custom character
        // Parameters:
        //   1. Array of 1-8 8-bit values defining a pixel image
        //      The data is passed as columns
        //   2. Boolean indicating whether the icon should be displayed
        //      centred on the screen
        // Returns: nothing

        if (glyphMatrix == null || typeof glyphMatrix != "array") {
            if (_debug) _logger.error("HT16K33Matrix.displayIcon() passed undefined icon array");
            return;
        }

        if (glyphMatrix.len() < 1 || glyphMatrix.len() > 8) {
            if (_debug) _logger.error("HT16K33Matrix.displayIcon() passed incorrectly sized icon array");
            return;
        }

        _buffer = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];

        for (local i = 0 ; i < glyphMatrix.len() ; ++i) {
            local a = i;
            if (center) a = i + ((8 - glyphMatrix.len()) / 2).tointeger();

            if (_inverseVideoFlag) {
                _buffer[a] = ~glyphMatrix[i];
            } else {
                _buffer[a] = glyphMatrix[i];
            }
        }

        _writeDisplay();
    }

    function displayCharacter(asciiValue = 32, center = false) {
        // Display a single character specified by its Ascii value
        // Parameters:
        //   1. Character Ascii code (default: 32 [space])
        //   2. Boolean indicating whether to center the character (true) or left-align (false) (default: false)
        // Returns: nothing

        displayChar(asciiValue, center);
    }

    function displayChar(asciiValue = 32, center = false) {
        local inputMatrix;
        if (asciiValue < 32) {
             inputMatrix = clone(_defchars[asciiValue]);
        } else {
            asciiValue = asciiValue - 32;
            if (asciiValue < 0 || asciiValue > _alphaCount) asciiValue = 0;
            inputMatrix = clone(_pcharset[asciiValue]);
        }

        _buffer = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];

        for (local i = 0 ; i < inputMatrix.len() ; ++i) {
            local a = i;
            if (center) a = i + ((8 - inputMatrix.len()) / 2).tointeger();

            if (_inverseVideoFlag) {
                _buffer[a] = _flip(~inputMatrix[i]);
            } else {
                _buffer[a] = _flip(inputMatrix[i]);
            }
        }

        _writeDisplay();
    }

    function displayLine(line) {
        // Bit-scroll through the characters in the variable ‘line’
        // Parameters:
        //   1. String of text
        // Returns: nothing

        if (line == null || line == "") {
            if (_debug) _logger.error("HT16K33Matrix.displayLine() sent a null or zero-length string");
            return;
        }

        foreach (index, character in line) {
            local glyph;
            if (character < 32) {
                if (_defchars[character] == -1 || (typeof _defchars[character] != "array")) {
                    if (_debug) _logger.log("Use of undefined character (" + character + ") in HT16K33Matrix.displayLine()");
                    glyph = clone(_pcharset[0]);
                } else {
                    glyph = clone(_defchars[character]);
                }
            } else {
                glyph = clone(_pcharset[character - 32]);
                glyph.append(0x00);
            }

            foreach (column, columnValue in glyph) {
                local cursor = column;
                local glyphToDraw = glyph;
                local increment = 1;
                local outputFrame = [0,0,0,0,0,0,0,0];
                for (local k = 0 ; k < 8 ; ++k) {
                    if (cursor < glyphToDraw.len()) {
                        outputFrame[k] = _flip(glyphToDraw[cursor]);
                        ++cursor;
                    } else {
                        if (index + increment < line.len()) {
                            if (line[index + increment] < 32) {
                                if (_defchars[line[index + increment]] == -1 || (typeof _defchars[line[index + increment]] != "array")) {
                                    if (_debug) _logger.log("Use of undefined character (" + line[index + increment] + ") in HT16K33Matrix.displayLine()");
                                    glyphToDraw = clone(_pcharset[0]);
                                } else {
                                    glyphToDraw = clone(_defchars[line[index + increment]]);
                                }
                            } else {
                                glyphToDraw = clone(_pcharset[line[index + increment] - 32]);
                                glyphToDraw.append(0x00);
                            }
                            ++increment;
                            cursor = 1;
                            outputFrame[k] = _flip(glyphToDraw[0]);
                        }
                    }
                }

                for (local k = 0 ; k < 8 ; ++k) {
                    if (_inverseVideoFlag) {
                        _buffer[k] = ~outputFrame[k];
                    } else {
                        _buffer[k] = outputFrame[k];
                    }
                }

                // Pause between frames according to level of rotation
                if (_rotationAngle == 0) {
                    imp.sleep(0.060);
                } else {
                    imp.sleep(0.045);
                }

                _writeDisplay();
            }
        }
    }

    function defineCharacter(asciiCode = 0, glyphMatrix = null) {
        defineChar(asciiCode, glyphMatrix);
    }

    function defineChar(asciiCode = 0, glyphMatrix = null) {
        // Set a user-definable char for later use
        // Parameters:
        //   1. Character Ascii code 0-31 (default: 0)
        //   2. Array of 1-8 8-bit values defining a pixel image
        //      The data is passed as columns
        // Returns: nothing

        if (glyphMatrix == null || typeof glyphMatrix != "array") {
            if (_debug) _logger.error("HT16K33Matrix.defineChar() passed undefined icon array");
            return;
        }

        if (glyphMatrix.len() < 1 || glyphMatrix.len() > 8) {
            if (_debug) _logger.error("HT16K33Matrix.defineChar() passed incorrectly sized icon array");
            return;
        }

        if (asciiCode < 0 || asciiCode > 31) {
            if (_debug) _logger.error("HT16K33Matrix.defineChar() passed an incorrect character code");
            return;
        }

        if (asciiCode in _defchars && _debug) _logger.log("Character " + asciiCode + " already defined so redefining it");

        local matrix = [];
        for (local i = 0 ; i < glyphMatrix.len() ; ++i) {
            matrix.append(_flip(glyphMatrix[i]));
        }

        if (_debug) _logger.log("Setting user-defined character " + asciiCode);
        //_defchars.insert(asciiCode, matrix);
        if (asciiCode in _defchars) {
            _defchars[asciiCode] = matrix;
        } else {
            _defchars[asciiCode] <- matrix;
        }
    }

    function plot(x, y, ink = 1, xor = false) {
        // Plot a point on the matrix. (0,0) is bottom left as viewed
        // Parameters:
        //   1. Integer X co-ordinate (0 - 7)
        //   2. Integer Y co-ordinate (0 - 7)
        //   3. Integer ink color: 1 = white, 0 = black (NOTE inverse video mode reverses this)
        //   4. Boolean indicating whether a pixel already color ink should be inverted
        // Returns:
        //   this

        if (x < 0 || x > 7) {
            _logger.error("HT16K33Matrix.plot() X co-ordinate out of range (0-7)");
            return;
        }

        if (y < 0 || y > 7) {
            _logger.error("HT16K33Matrix.plot() Y co-ordinate out of range (0-7)");
            return;
        }

        if (ink != 1 && ink != 0) ink = 1;
        if (_inverseVideoFlag) ink = ((ink == 1) ? 0 : 1);

        local row = _buffer[x];
        if (ink == 1) {
            // We want to set the pixel
            local bit = row & (1 << (7 - y));
            if (bit > 0 && xor) {
                // Pixel is already set, but xor is true so clear the pixel
                row = row & (0xFF - (1 << (7 - y)));
            } else {
                // Pixel is clear so set it
                row = row | (1 << (7 - y));
            }
        } else {
            // We want to clear the pixel
            local bit = row & (1 << (7 - y));
            if (bit == 0 && xor) {
                // Pixel is already clear, but xor is true so invert the pixel
                row = row | (1 << (7 - y));
            } else {
                // Pixel is set so clear it
                row = row & (0xFF - (1 << (7 - y)));
            }
        }

        _buffer[x] = row;
        return this;
    }

    function draw() {
        _writeDisplay();
    }

    function powerDown() {
        if (_debug) _logger.log("Turning the HT16K33 Matrix off");
        _led.write(_ledAddress, HT16K33_MAT_CLASS_REGISTER_DISPLAY_OFF);
        _led.write(_ledAddress, HT16K33_MAT_CLASS_REGISTER_SYSTEM_OFF);
    }

    function powerUp() {
        if (_debug) _logger.log("Turning the HT16K33 Matrix on");
        _led.write(_ledAddress, HT16K33_MAT_CLASS_REGISTER_SYSTEM_ON);
        _led.write(_ledAddress, HT16K33_MAT_CLASS_REGISTER_DISPLAY_ON);
    }

    // ****** PRIVATE FUNCTIONS - DO NOT CALL ******

    function _writeDisplay() {
        // Takes the contents of _buffer and writes it to the LED matrix
        // Uses function processByte() to manipulate regular values to
        // Adafruit 8x8 matrix's format
        local dataString = HT16K33_MAT_CLASS_DISPLAY_ADDRESS;
        local writedata = clone(_buffer);
        if (_rotationAngle != 0) writedata = _rotateMatrix(writedata, _rotationAngle);

        for (local i = 0 ; i < 8 ; ++i) {
            dataString = dataString + (_processByte(writedata[i])).tochar() + "\x00";
        }

        _led.write(_ledAddress, dataString);
    }

    function _flip(value) {
        // Function used to manipulate pre-defined character matrices
        // ahead of rotation by changing their byte order
        local a = 0;
        local b = 0;

        for (local i = 0 ; i < 8 ; ++i) {
            a = value & (1 << i);
            if (a > 0) b = b + (1 << (7 - i));
        }

        return b;
    }

    function _rotateMatrix(inputMatrix, angle = 0) {
        // Value of angle determines the rotation:
        // 0 = none, 1 = 90 clockwise, 2 = 180, 3 = 90 anti-clockwise
        if (angle == 0) return inputMatrix;

        local a = 0;
        local lineValue = 0;
        local outputMatrix = [0,0,0,0,0,0,0,0];

        // Note: it's quicker to have three case-specific
        // code blocks than a single, generic block
        switch(angle) {
            case 1:
                for (local y = 0 ; y < 8 ; ++y) {
                    lineValue = inputMatrix[y];
                    for (local x = 7 ; x > -1 ; --x) {
                        a = lineValue & (1 << x);
                        if (a != 0) outputMatrix[7 - x] = outputMatrix[7 - x] + (1 << y);
                    }
                }
                break;

            case 2:
                for (local y = 0 ; y < 8 ; ++y) {
                    lineValue = inputMatrix[y];
                    for (local x = 7 ; x > -1 ; --x) {
                        a = lineValue & (1 << x);
                        if (a != 0) outputMatrix[7 - y] = outputMatrix[7 - y] + (1 << (7 - x));
                    }
                }
                break;

            case 3:
                for (local y = 0 ; y < 8 ; ++y) {
                    lineValue = inputMatrix[y];
                    for (local x = 7 ; x > -1 ; --x) {
                        a = lineValue & (1 << x);
                        if (a != 0) outputMatrix[x] = outputMatrix[x] + (1 << (7 - y));
                    }
                }
                break;
        }

        return outputMatrix;
    }

    function _processByte(byteValue) {
        // Adafruit 8x8 matrix requires some data manipulation:
        // Bits 7-0 of each line need to be sent 0 through 7,
        // and bit 0 rotate to bit 7

        local result = 0;
        local a = 0;
        for (local i = 0 ; i < 8 ; ++i) {
            // Run through each bit in byteValue and set the
            // opposite bit in result accordingly, ie. bit 0 -> bit 7,
            // bit 1 -> bit 6, etc.
            a = byteValue & (1 << i);
            if (a > 0) result = result + (1 << (7 - i));
        }

        // Get bit 0 of result
        result & 0x01;

        // Shift result bits one bit to right
        result = result >> 1;

        // if old bit 0 is set, set new bit 7
        if (a > 0) result = result + 0x80;
        return result;
    }

    // ********** EXPERIMENTAL ***********

    function animate(strings = null, completeCallback = null) {
        // Display the strings in the array as per displayLine()
        // but with the strings displayed alternately to provide
        // a basic animation feature as the two scroll

        if (strings == null || typeof strings != "array") {
            if (_debug) _logger.error("HT16K33Matrix.animate() takes an array of strings");
            return;
        }

        // 'animate()' needs at least two strings
        if (strings.len() < 2) {
            if (_debug) _logger.error("HT16K33Matrix.animate() takes an array of two or more strings");
            return;
        }

        // Strings must be the same length
        for (local i = 1 ; i < strings.len() ; i++) {
            local a = strings[i - 1];
            local b = strings[i];

            if (a.len() != b.len()) {
                if (_debug) _logger.error("HT16K33Matrix.animate() takes an array of strings of equal length");
                return;
            }
        }

        // Set/initialise the animation variables
        _aStrings = strings;
        _aCharIndex = 0;        // Character in the string
        _aSliceIndex = 0;       // Column inset at which the frame starts
        _aSeqIndex = 0;         // Which string to display
        _aCb = completeCallback;

        // Start animating
        _animateFrame();
    }

    function stopAnimate() {
        // Stop the animation flow
        if (_aTimer != null) imp.cancelwakeup(_aTimer);
        _aTimer = null;
    }

    function _animateFrame() {
        // Clear the frame
        this._buffer = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];

        local glyph;
        local index = 0;
        local sliceIndex = this._aSliceIndex;
        local charIndex = this._aCharIndex;

        // Get the current string
        local frameString = _aStrings[this._aSeqIndex];

        do {
            local c;

            try {
                // Get the current character from the current string
                c = frameString[charIndex];
            } catch(err) {
                break;
            }

            if (c < 32) {
                // Display a user-defined character
                if (this._defchars[c] == -1 || (typeof this._defchars[c] != "array")) {
                    // Character not defined; present a space instead
                    glyph = clone(this._pcharset[0]);
                    glyph.append(0x00);
                } else {
                    glyph = clone(this._defchars[c]);
                }
            } else {
                // Display a standard Ascii character
                glyph = clone(this._pcharset[c - 32]);
                glyph.append(0x00);
            }

            for (local i = sliceIndex ; i < glyph.len() ; i++) {
                // Display however many rows of the 8x8 matrix will be taken up
                // by the visible rows of the lead character glyph
                this._buffer[index] = _flip(glyph[i]);
                index++;

                // Break if the character glyph contains more rows than there
                // are free rows in the buffer
                if (index > 7) break;
            }

            // Start at the first row of the next character and advance
            // the character index by one
            sliceIndex = 0;
            charIndex++;

        } while (index < 8)

        // Handle any required rotation and write the buffer to the matrix
        if (this._rotateFlag) this._buffer = _rotateMatrix(this._buffer, this._rotationAngle);
        _writeDisplay();

        // Load in the current glyph to see if we're at its end
        local c = frameString[this._aCharIndex];

        if (c < 32) {
            // User-defined character?
            if (this._defchars[c] == -1 || (typeof this._defchars[c] != "array")) {
                // Yes, but it's undefined so use a space
                glyph = clone(this._pcharset[0]);
                glyph.append(0x00);
            } else {
                glyph = clone(this._defchars[c]);
            }
        } else {
            // No, so use a standard Ascii character
            glyph = clone(this._pcharset[c - 32]);
            glyph.append(0x00);
        }

        // If the start row is greater than the characters length, we
        // start the next frame with a new character from the string
        if (this._aSliceIndex > glyph.len()) {
            this._aSliceIndex = 0;
            ++this._aCharIndex;
        }

        // If we still have sufficient characters to animate onto the matrix,
        // set the next frame to be rendered in 0.1s' time
        if (this._aCharIndex < frameString.len() - 1) {
            // Move on to the next string
            _aSeqIndex++;

            if (_aSeqIndex == _aStrings.len()) {
                // We've run through the x strings, so go back to the first
                // and move on a column
                _aSeqIndex = 0;
                this._aSliceIndex++;
            }
        }
        else
        {
            _aCb();
        }

        _aTimer = imp.wakeup(0.1, _animateFrame.bindenv(this));
    }
}
