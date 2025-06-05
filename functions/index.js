// Firebase Functions v2
const {onRequest} =
require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
setGlobalOptions({region: "europe-west1"});
const {defineString} = require("firebase-functions/params");

// Importing the Google Generative AI library
const {GoogleGenerativeAI,
  HarmCategory,
  HarmBlockThreshold} = require("@google/generative-ai");

// Defining the environment variable for the Gemini API key
const GEMINI_API_KEY_PARAM = defineString("GEMINI_API_KEY");
// Importing the Firebase Functions config
let genAI;
let model;
// Check if the GEMINI_API_KEY is set in Firebase functions config
if (GEMINI_API_KEY_PARAM.value()) {
  genAI = new GoogleGenerativeAI(GEMINI_API_KEY_PARAM.value()),
  model = genAI.getGenerativeModel({
    model: "gemini-2.0-flash",
    safetySettings: [
      {category: HarmCategory.HARM_CATEGORY_HARASSMENT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
      {
        category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
      {category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
      {category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
    ],
  });
} else {
  console.error("GEMINI_API_KEY is not set in Firebase functions config");
}


exports.geminiProxy = onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  if (!model) {
    console.error("Model is not initialized");
    res.status(500).send({error: "Model is not initialized"});
    return;
  }

  if (req.method !== "POST") {
    res.status(405).send({error: "Only POST requests are allowed"});
    return;
  }

  const userPrompt = req.body.prompt;
  if (!userPrompt) {
    res.status(400).send({error: "Prompt is required"});
    return;
  }
  try {
    const result = await model.generateContent(userPrompt);
    const geminiAPIResponse = await result.response;
    const text = geminiAPIResponse.text();

    res.status(200).send({reply: text});
  } catch (error) {
    console.error("Error with connecting to Gemini API:", error);
    // Log the error with connecting to Gemini API
    if (error.message && error.message.includes("blocked")) {
      res.status(400).send({error: "Content blocked by safety settings"});
    } else {
      res.status(500).send({error: "Internal server error"});
    }
  }
});
