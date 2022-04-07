package com.ai.sentiments.fn;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ser.impl.SimpleFilterProvider;
import com.oracle.bmc.ailanguage.AIServiceLanguageClient;
import com.oracle.bmc.ailanguage.model.DetectLanguageKeyPhrasesDetails;
import com.oracle.bmc.ailanguage.model.DetectLanguageKeyPhrasesResult;
import com.oracle.bmc.ailanguage.requests.DetectLanguageKeyPhrasesRequest;
import com.oracle.bmc.ailanguage.responses.DetectLanguageKeyPhrasesResponse;
import com.oracle.bmc.auth.AbstractAuthenticationDetailsProvider;
import com.oracle.bmc.auth.ResourcePrincipalAuthenticationDetailsProvider;
import com.oracle.bmc.http.internal.ExplicitlySetFilter;
import com.oracle.bmc.model.BmcException;
import com.streaming.input.pojo.Input;

public class TaskFunction {

	private static ObjectMapper objectMapper = new ObjectMapper();
	static{
		SimpleFilterProvider filterProvider = new SimpleFilterProvider();
	      	filterProvider.addFilter("explicitlySetFilter",
	      			ExplicitlySetFilter.INSTANCE);
					  objectMapper.setFilterProvider(filterProvider);
	}

	public String handleRequest(List<Input> input) {

		AbstractAuthenticationDetailsProvider provider = 
		
		ResourcePrincipalAuthenticationDetailsProvider.builder().build();

		AIServiceLanguageClient client = AIServiceLanguageClient.builder().build(provider);

		List<DetectLanguageKeyPhrasesResult> output = new ArrayList<>();
		for (Input string : input) {

			byte[] decodedBytes = Base64.getDecoder().decode(string.getValue());

			String tweetString = new String(decodedBytes);

			JsonNode node = null;
			try {
				node = objectMapper.readTree(tweetString).get("User").get("Description");
			} catch (JsonMappingException e) {
				e.printStackTrace();
			} catch (JsonProcessingException e) {
				e.printStackTrace();
			}

			
			if(node==null)
			continue;
			
			String description = node.asText();

			System.out.println("Description text for detection - "+ description);

			DetectLanguageKeyPhrasesDetails detectKeyPhrase = DetectLanguageKeyPhrasesDetails.builder().text(description).build();
			
			DetectLanguageKeyPhrasesRequest r = DetectLanguageKeyPhrasesRequest.builder().detectLanguageKeyPhrasesDetails(detectKeyPhrase)
					.opcRequestId("RF9PKZSQ4CYTKJJHWNTT" + UUID.randomUUID().toString()).build();
			
			try {
				DetectLanguageKeyPhrasesResponse detectLanguageKeyPhrases = client.detectLanguageKeyPhrases(r);
				output.add(detectLanguageKeyPhrases.getDetectLanguageKeyPhrasesResult());
			} catch (BmcException e) {
				System.out.println("Error in detection -"+e.getMessage());
			}

		}

		String json;
		try {

        	json = objectMapper.writeValueAsString(output);

		} catch (JsonProcessingException e) {
			throw new RuntimeException("Unable to convert to json", e);
		}

		return json;
	}

}