import {
  devLocalIndexerRef,
  devLocalVectorstore,
} from '@genkit-ai/dev-local-vectorstore';
import { gemini20FlashExp, googleAI, textEmbeddingGecko001} from '@genkit-ai/googleai'; 
import { z, genkit } from 'genkit';
import { run } from 'genkit';
import { Document } from 'genkit/retriever';
import { chunk } from 'llm-chunk';
import { readFile } from 'fs/promises';
import path from 'path';
import pdf from 'pdf-parse';
import { devLocalRetrieverRef } from '@genkit-ai/dev-local-vectorstore';
import { onFlow } from "@genkit-ai/firebase/functions";
import * as dotenv from 'dotenv';
import { firebaseAuth } from '@genkit-ai/firebase/auth';


dotenv.config();
const apiKey: string = process.env.API_KEY ?? '';

const ai = genkit({
  plugins: [
    // Google AI provides the textEmbedding embedder
    googleAI(),

    // the local vector store requires an embedder to translate from text to vector
    devLocalVectorstore([
      {
        indexName: 'csBook',
        embedder: textEmbeddingGecko001, 
      },
    ]),
  ],
});

export const csBookIndexer = devLocalIndexerRef('csBook'); // Changed indexer name

const chunkingConfig = {
  minLength: 500, 
  maxLength: 1000,
  splitter: 'sentence',
  overlap: 100,
  delimiters: '',
} as any;

async function extractTextFromPdf(filePath: string) {
  const pdfFile = path.resolve(filePath);
  const dataBuffer = await readFile(pdfFile);
  const data = await pdf(dataBuffer);
  return data.text;
}


// export const indexCsBook = onFlow(
//   ai,
//   {
//     name: "indexCsBook",
//     inputSchema: z.string(),
//     outputSchema: z.string(),
//     authPolicy: firebaseAuth((user, input) => {
//       if (!user.email_verified) {
//         throw new Error("Verified email required to run flow");
//       }
//     }),
//     httpsOptions: {
//       secrets: [apiKey],
//       cors: '*',
//     },
//   },
//   async (filePath: string) => {
//     filePath = path.resolve(filePath);

//     // Read the pdf.
//     const pdfTxt = await run('extract-text', () =>
//       extractTextFromPdf(filePath)
//     );

//     // Divide the pdf text into segments.
//     const chunks = await run('chunk-it', async () =>
//       chunk(pdfTxt, chunkingConfig)
//     );

//     // Convert chunks of text into documents to store in the index.
//     const documents = chunks.map((text) => {
//       return Document.fromText(text, { filePath });
//     });

//     // Add documents to the index.
//     await ai.index({
//       indexer: csBookIndexer,
//       documents,
//     });
//     return 'Success';
//   }
  

// );

export const indexCsBook = ai.defineFlow(
  {
    name: 'indexCsBook',
    inputSchema: z.string().describe('PDF file path'),
    outputSchema: z.void(),
  },
  async (filePath: string) => {
    filePath = path.resolve(filePath);

    // Read the pdf.
    const pdfTxt = await run('extract-text', () =>
      extractTextFromPdf(filePath)
    );

    // Divide the pdf text into segments.
    const chunks = await run('chunk-it', async () =>
      chunk(pdfTxt, chunkingConfig)
    );

    // Convert chunks of text into documents to store in the index.
    const documents = chunks.map((text) => {
      return Document.fromText(text, { filePath });
    });

    // Add documents to the index.
    await ai.index({
      indexer: csBookIndexer,
      documents,
    });
  }
);

// Define the retriever reference
export const csBookRetriever = devLocalRetrieverRef('csBook'); 


// export const csBookQAFlow = onFlow(
//   ai,
//   {
//     name: "csBookQA",
//     inputSchema: z.string(),
//     outputSchema: z.string(),
//     authPolicy: firebaseAuth((user, input) => {
//       if (!user.email_verified) {
//         throw new Error("Verified email required to run flow");
//       }
//     }),
//     httpsOptions: {
//       secrets: [apiKey],
//       cors: '*',
//     },
//   },
//   async (input: string) => {
//     // retrieve relevant documents
//     const docs = await ai.retrieve({
//       retriever: csBookRetriever,
//       query: input,
//       options: { k: 3 },
//     });

//     // generate a response
//     const { text } = await ai.generate({
//       model: gemini20FlashExp,
//       prompt: `
// You are acting as a helpful AI assistant that can answer 
// questions about the content of the provided CS book. 

// Use only the context provided to answer the question.
// If you don't know, do not make up an answer.
// Do not add or change information from the book.

// Question: ${input}`,
//       docs,
//     });

//     return text;
//   }
// );

export const csBookQAFlow = ai.defineFlow(
  { name: 'csBookQA', inputSchema: z.string(), outputSchema: z.string() },
  async (input: string) => {
    // retrieve relevant documents
    const docs = await ai.retrieve({
      retriever: csBookRetriever,
      query: input,
      options: { k: 3 },
    });

    // generate a response
    const { text } = await ai.generate({
      model: gemini20FlashExp,
      prompt: `
You are acting as a helpful AI assistant that can answer 
questions about the content of the provided CS book. 

Use only the context provided to answer the question.
If you don't know, do not make up an answer.
Do not add or change information from the book.

Question: ${input}`,
      docs,
    });

    return text;
  }
);